/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

/**
 * Determines the `VerifiedIdStatus` of a `VerifiedId`: first expiry (from the credential's own
 * `expiresOn`, no network), then W3C StatusList2021 (fetch the issuer's list and check the bit).
 *
 * Status lists are resolved three ways, mirroring the Entra server: a direct HTTPS
 * `statusListCredential`, a `did:web` reference (resolved to a service endpoint), or the legacy
 * IdentityHub form (`urn:uuid:` id or `did:`-relative credential), which resolves the issuer's
 * IdentityHub and POSTs a CollectionsQuery. Every fetched status list JWT is signature-verified and
 * bound to the credential's issuer before its bits are trusted.
 *
 * The check is fail-open: every network, parsing, or verification failure resolves to `.unknown` so
 * a check that can't complete never blocks the user. The server remains authoritative at presentation.
 */
class StatusCheckService {

    private let configuration: LibraryConfiguration
    private let validator: StatusListTokenValidator
    private let dateProvider: () -> Date

    init(configuration: LibraryConfiguration,
         validator: StatusListTokenValidator? = nil,
         dateProvider: @escaping () -> Date = { Date() }) {
        self.configuration = configuration
        self.validator = validator
            ?? StatusListTokenValidator(didResolver: DIDDocumentNetworkCalls(urlSession: .shared))
        self.dateProvider = dateProvider
    }

    /// W3C StatusList2021 `statusPurpose` values. A credential's declared purpose must match the
    /// fetched status list's purpose before its bit is trusted, and the purpose selects whether a
    /// set bit means `.suspended` or `.revoked`.
    static let statusPurposeRevocation = "revocation"
    static let statusPurposeSuspension = "suspension"

    func checkStatus(of verifiedId: VerifiedId) async -> VerifiedIdStatus {
        if let expiresOn = verifiedId.expiresOn, expiresOn < dateProvider() {
            return .expired
        }

        // Both concrete VerifiedId types (`VCVerifiedId` and `OpenID4VCIVerifiedId`) conform to
        // `InternalVerifiedId` and expose `.raw`, which is all the status parsing needs. Casting to the
        // protocol — not a concrete type — keeps OpenID4VCI credentials in scope. An unrecognised type
        // is `.unknown` (indeterminate), never `.noStatusEndpoint`, so a caller can't read it as "no
        // status to check" and accept a credential whose status this SDK simply couldn't inspect.
        guard let credential = verifiedId as? InternalVerifiedId else {
            configuration.logger.logVerbose(message: "StatusCheck: unsupported VerifiedId type; status is indeterminate.")
            return .unknown
        }

        let descriptors = StatusCheckService.parseCredentialStatuses(from: credential.raw)
        guard !descriptors.isEmpty else {
            configuration.logger.logVerbose(message: "StatusCheck: credential has no parseable credentialStatus; treating as no status endpoint.")
            return .noStatusEndpoint
        }

        let issuerDid = credential.raw.content.iss ?? ""
        return await evaluateAllStatusLists(descriptors: descriptors, issuerDid: issuerDid)
    }

    /// Evaluates every `credentialStatus` entry and combines them. StatusList2021 models revocation and
    /// suspension as separate entries (distinct `statusPurpose`), so an issuer that supports both emits
    /// two; checking only the first would let a set suspension bit be missed behind a clear revocation
    /// bit. Revocation has priority (and short-circuits); an indeterminate entry downgrades the result
    /// to `.unknown` rather than reporting a definitive `.valid` while ignoring data.
    private func evaluateAllStatusLists(descriptors: [CredentialStatusDescriptor],
                                        issuerDid: String) async -> VerifiedIdStatus {
        var sawSuspended = false
        var sawUnknown = false
        var sawValid = false

        for descriptor in descriptors {
            switch await fetchAndCheckStatusList(descriptor: descriptor, issuerDid: issuerDid) {
            case .revoked:
                return .revoked
            case .suspended:
                sawSuspended = true
            case .valid:
                sawValid = true
            case .expired, .unknown, .noStatusEndpoint:
                sawUnknown = true
            }
        }

        if sawSuspended { return .suspended }
        if sawUnknown { return .unknown }
        return sawValid ? .valid : .unknown
    }

    private func fetchAndCheckStatusList(descriptor: CredentialStatusDescriptor,
                                         issuerDid: String) async -> VerifiedIdStatus {
        let statusListCredential = descriptor.effectiveStatusListCredential

        if let statusListCredential = statusListCredential,
           let url = await resolveStatusListURL(statusListCredential) {
            return await checkDirectStatusList(url: url, descriptor: descriptor, issuerDid: issuerDid)
        }

        if statusListCredential?.hasPrefix("did:") == true || descriptor.id.hasPrefix("urn:uuid:") {
            guard !issuerDid.isEmpty else {
                configuration.logger.logVerbose(message: "StatusCheck: IdentityHub status list requires an issuer DID, but none was present.")
                return .unknown
            }
            return await checkStatusViaIdentityHub(descriptor: descriptor, issuerDid: issuerDid)
        }

        configuration.logger.logVerbose(message: "StatusCheck: credential status uses an unsupported status list reference.")
        return .unknown
    }

    // MARK: - Direct (HTTPS / did:web) path

    private func checkDirectStatusList(url: URL,
                                       descriptor: CredentialStatusDescriptor,
                                       issuerDid: String) async -> VerifiedIdStatus {
        do {
            let responseData = try await configuration.networking.fetch(url: url,
                                                                        StatusListCredentialFetchOperation.self)
            guard let jwt = StatusCheckService.compactJws(from: responseData),
                  let statusList = await verifyAndExtractStatusList(fromJws: jwt, issuerDid: issuerDid) else {
                configuration.logger.logVerbose(message: "StatusCheck: status list credential could not be parsed or verified.")
                return .unknown
            }
            return StatusCheckService.evaluate(statusList: statusList,
                                               descriptor: descriptor,
                                               bitIndex: descriptor.effectiveStatusListIndex)
        } catch {
            configuration.logger.logVerbose(message: "StatusCheck: failed to fetch status list credential.")
            return .unknown
        }
    }

    /// Resolves the status list credential to a fetchable HTTPS URL: a direct `https://` URL, or a
    /// `did:web:` reference resolved through its DID document's service endpoint. Returns `nil` for
    /// anything else — including a `did:web:` reference carrying a `queries` parameter, which is the
    /// IdentityHub CollectionsQuery (POST) form — so the caller falls back to the IdentityHub path
    /// instead of GETting an endpoint that only answers POST.
    private func resolveStatusListURL(_ raw: String) async -> URL? {
        if raw.hasPrefix("https://") {
            return StatusCheckService.isWellFormedHttpsURL(raw) ? URL(string: raw) : nil
        }
        if raw.hasPrefix("did:web:") {
            if StatusCheckService.didURLQueryParameter(raw, key: "queries") != nil {
                return nil
            }
            return await resolveDidWebURL(raw)
        }
        return nil
    }

    private func resolveDidWebURL(_ didURL: String) async -> URL? {
        let did = didURL.components(separatedBy: "?").first ?? didURL
        let serviceName = StatusCheckService.didURLQueryParameter(didURL, key: "service") ?? "IdentityHub"
        let queries = StatusCheckService.didURLQueryParameter(didURL, key: "queries")

        guard let services = await resolveDIDDocumentServices(did: did),
              let service = StatusCheckService.findService(services, named: serviceName),
              let endpoint = StatusCheckService.serviceEndpointURL(from: service) else {
            configuration.logger.logVerbose(message: "StatusCheck: could not resolve a did:web service endpoint for the status list.")
            return nil
        }

        guard StatusCheckService.isWellFormedHttpsURL(endpoint) else {
            configuration.logger.logVerbose(message: "StatusCheck: resolved did:web status list endpoint is not a well-formed HTTPS URL.")
            return nil
        }

        guard let queries = queries else {
            return URL(string: endpoint)
        }
        guard var components = URLComponents(string: endpoint) else { return nil }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: "queries", value: queries))
        components.queryItems = items
        return components.url
    }

    // MARK: - IdentityHub (urn:uuid / did:-relative) path

    private func checkStatusViaIdentityHub(descriptor: CredentialStatusDescriptor,
                                           issuerDid: String) async -> VerifiedIdStatus {
        guard let objectId = resolveIdentityHubObjectId(descriptor: descriptor) else {
            return .unknown
        }
        let bitIndex = resolveStatusListBitIndex(descriptor: descriptor)

        // Resolve the issuer's DID document once and reuse it both to locate the IdentityHub endpoint
        // (from the raw `instances` form the typed model omits) and to verify the status list
        // signature, avoiding a second fetch of the same document inside the validator.
        let issuerDocument = await resolveDIDDocument(did: issuerDid)

        guard let services = issuerDocument.services,
              let hubService = StatusCheckService.findService(services, named: "IdentityHub"),
              let hubEndpoint = StatusCheckService.serviceEndpointURL(from: hubService) else {
            configuration.logger.logVerbose(message: "StatusCheck: issuer DID document has no IdentityHub service endpoint.")
            return .unknown
        }

        guard StatusCheckService.isWellFormedHttpsURL(hubEndpoint), let hubURL = URL(string: hubEndpoint) else {
            configuration.logger.logVerbose(message: "StatusCheck: IdentityHub endpoint is not a well-formed HTTPS URL.")
            return .unknown
        }

        do {
            let requestBody = StatusCheckService.buildCollectionsQueryBody(issuerDid: issuerDid, objectId: objectId)
            let responseData = try await configuration.networking.post(requestBody: requestBody,
                                                                       url: hubURL,
                                                                       CollectionsQueryPostOperation.self)
            guard let responseBody = String(data: responseData, encoding: .utf8) else {
                configuration.logger.logVerbose(message: "StatusCheck: IdentityHub response was not valid UTF-8.")
                return .unknown
            }

            var statusList = await verifyAndExtractStatusList(fromJws: responseBody,
                                                              issuerDid: issuerDid,
                                                              issuerDocument: issuerDocument.document)
            if statusList == nil {
                statusList = await extractStatusListFromCollectionsResponse(responseBody,
                                                                            issuerDid: issuerDid,
                                                                            issuerDocument: issuerDocument.document)
            }

            guard let resolved = statusList else {
                configuration.logger.logVerbose(message: "StatusCheck: no verifiable status list found in IdentityHub response.")
                return .unknown
            }
            return StatusCheckService.evaluate(statusList: resolved, descriptor: descriptor, bitIndex: bitIndex)
        } catch {
            configuration.logger.logVerbose(message: "StatusCheck: failed to query IdentityHub for the status list.")
            return .unknown
        }
    }

    /// IdentityHub object id (status list UUID) from a `urn:uuid:<id>?...` id or a
    /// `did:...?queries=<base64url([{objectId}])>` credential.
    private func resolveIdentityHubObjectId(descriptor: CredentialStatusDescriptor) -> String? {
        if descriptor.id.hasPrefix("urn:uuid:") {
            let body = String(descriptor.id.dropFirst("urn:uuid:".count))
            return body.components(separatedBy: "?").first
        }

        guard let statusCredential = descriptor.effectiveStatusListCredential,
              statusCredential.hasPrefix("did:") else {
            return nil
        }
        guard let encodedQueries = StatusCheckService.didURLQueryParameter(statusCredential, key: "queries") else {
            configuration.logger.logVerbose(message: "StatusCheck: IdentityHub credential is missing a 'queries' parameter.")
            return nil
        }
        guard let decoded = Data(base64URLEncoded: encodedQueries) else {
            configuration.logger.logVerbose(message: "StatusCheck: IdentityHub 'queries' parameter is not valid base64url.")
            return nil
        }
        guard let array = try? JSONSerialization.jsonObject(with: decoded) as? [[String: Any]],
              let firstEntry = array.first else {
            configuration.logger.logVerbose(message: "StatusCheck: IdentityHub 'queries' did not decode to a non-empty array.")
            return nil
        }
        guard let objectId = firstEntry["objectId"] as? String else {
            configuration.logger.logVerbose(message: "StatusCheck: IdentityHub query entry is missing 'objectId'.")
            return nil
        }
        return objectId
    }

    /// Bit index from the `urn:uuid:...?bit-index=N` id when present, else the descriptor's index.
    private func resolveStatusListBitIndex(descriptor: CredentialStatusDescriptor) -> Int {
        if descriptor.id.hasPrefix("urn:uuid:"),
           let value = StatusCheckService.didURLQueryParameter(descriptor.id, key: "bit-index"),
           let bitIndex = Int(value) {
            return bitIndex
        }
        return descriptor.effectiveStatusListIndex
    }

    /// Extracts the status list from a CollectionsQuery envelope: each `replies[].entries[].data` is a
    /// base64url-encoded JWT, decoded and verified via `verifyAndExtractStatusList` (raw value tried too).
    private func extractStatusListFromCollectionsResponse(_ responseBody: String,
                                                          issuerDid: String,
                                                          issuerDocument: IdentifierDocument? = nil) async -> (encodedList: String, statusPurpose: String)? {
        guard let data = responseBody.data(using: .utf8),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let replies = root["replies"] as? [[String: Any]] else {
            return nil
        }

        for reply in replies {
            guard let entries = reply["entries"] as? [[String: Any]] else { continue }
            for entry in entries {
                guard let entryData = entry["data"] as? String else { continue }
                if let decoded = StatusCheckService.base64DecodeToString(entryData),
                   let result = await verifyAndExtractStatusList(fromJws: decoded, issuerDid: issuerDid, issuerDocument: issuerDocument) {
                    return result
                }
                if let result = await verifyAndExtractStatusList(fromJws: entryData, issuerDid: issuerDid, issuerDocument: issuerDocument) {
                    return result
                }
            }
        }
        return nil
    }

    // MARK: - Verify + extract

    /// Verifies a status list JWT (signature bound to `issuerDid`, plus `exp`) and returns its
    /// `encodedList` / `statusPurpose`. Returns `nil` for an unsigned body or any failed check, so the
    /// SDK never reads bits from unverified data.
    private func verifyAndExtractStatusList(fromJws jws: String,
                                            issuerDid: String,
                                            issuerDocument: IdentifierDocument? = nil) async -> (encodedList: String, statusPurpose: String)? {
        guard let token = JwsToken<StatusListClaims>(from: jws) else {
            return nil
        }
        do {
            try await validator.validate(token,
                                         expectedIssuerDid: issuerDid,
                                         now: dateProvider(),
                                         preResolvedDocument: issuerDocument)
        } catch let error as StatusListValidationError {
            configuration.logger.logVerbose(message: "StatusCheck: status list token failed validation (\(error)).")
            return nil
        } catch {
            configuration.logger.logVerbose(message: "StatusCheck: status list token validation could not complete.")
            return nil
        }
        return StatusCheckService.extractStatusListInfo(fromJws: jws)
    }

    // MARK: - Pure helpers

    /// Checks the status purpose matches (if declared), decompresses the list, and reads the bit.
    static func evaluate(statusList: (encodedList: String, statusPurpose: String),
                         descriptor: CredentialStatusDescriptor,
                         bitIndex: Int) -> VerifiedIdStatus {
        if !descriptor.statusPurpose.isEmpty, descriptor.statusPurpose != statusList.statusPurpose {
            return .unknown
        }
        guard let decoded = Data(base64URLEncoded: statusList.encodedList),
              let bitstring = decoded.gunzipped() else {
            return .unknown
        }
        guard let isFlagged = checkBit(bitstring, index: bitIndex) else {
            return .unknown
        }
        if !isFlagged {
            return .valid
        }
        return statusList.statusPurpose == statusPurposeSuspension ? .suspended : .revoked
    }

    /// Parses the credential's own `credentialStatus` entries from the raw VC payload. The decoded
    /// `VerifiableCredentialDescriptor` only carries `id` / `type`, so the richer status-list fields
    /// are read straight from the token payload here. Returns every entry (a `credentialStatus` may be
    /// a single object or an array of objects) so the caller can evaluate revocation and suspension
    /// independently.
    static func parseCredentialStatuses(from raw: VerifiableCredential) -> [CredentialStatusDescriptor] {
        guard let compact = raw.rawValue ?? (try? raw.serialize()),
              let payload = jsonPayload(ofCompactJws: compact),
              let vc = payload["vc"] as? [String: Any] else {
            return []
        }

        let entries: [[String: Any]]
        if let object = vc["credentialStatus"] as? [String: Any] {
            entries = [object]
        } else if let array = vc["credentialStatus"] as? [[String: Any]] {
            entries = array
        } else {
            entries = []
        }

        return entries.compactMap { CredentialStatusDescriptor(json: $0) }
    }

    /// Reads `encodedList` and `statusPurpose` (defaulting to `"revocation"`) from a status list JWT
    /// payload, accepting both the top-level `credentialSubject` and the nested `vc.credentialSubject`.
    static func extractStatusListInfo(fromJws jws: String) -> (encodedList: String, statusPurpose: String)? {
        guard let payload = jsonPayload(ofCompactJws: jws) else {
            return nil
        }

        let credentialSubject = (payload["credentialSubject"] as? [String: Any])
            ?? ((payload["vc"] as? [String: Any])?["credentialSubject"] as? [String: Any])

        guard let subject = credentialSubject,
              let encodedList = subject["encodedList"] as? String else {
            return nil
        }

        let statusPurpose = subject["statusPurpose"] as? String ?? statusPurposeRevocation
        return (encodedList, statusPurpose)
    }

    /// Reads the bit at [index] least-significant-bit-first (index 0 = LSB of byte 0), matching Entra's
    /// status list encoding. Returns `true` if set (revoked/suspended), `false` if clear (valid), or
    /// `nil` when [index] is outside the bitstring.
    static func checkBit(_ bitstring: Data, index: Int) -> Bool? {
        guard index >= 0 else { return nil }
        let byteIndex = index / 8
        let bitOffset = index % 8
        guard byteIndex < bitstring.count else { return nil }
        let byte = bitstring[bitstring.startIndex + byteIndex]
        return (Int(byte) & (1 << bitOffset)) != 0
    }

    static func isWellFormedHttpsURL(_ string: String) -> Bool {
        guard let url = URL(string: string),
              url.scheme?.lowercased() == "https",
              let host = url.host, !host.isEmpty else {
            return false
        }
        return true
    }

    /// Selects the named service from a DID document `service` array, by `type` or an `id` ending in
    /// `#<name>`.
    static func findService(_ services: [[String: Any]], named name: String) -> [String: Any]? {
        return services.first { service in
            let type = service["type"] as? String ?? ""
            let id = service["id"] as? String ?? ""
            return type == name || id.hasSuffix("#\(name)")
        }
    }

    /// Reads a service endpoint URL from a DID document service entry, accepting a bare string, an
    /// `{ instances: [...] }` (IdentityHub) or `{ origins: [...] }` (LinkedDomains) object, or an array.
    static func serviceEndpointURL(from service: [String: Any]) -> String? {
        let endpoint = service["serviceEndpoint"]
        if let string = endpoint as? String {
            return string
        }
        if let object = endpoint as? [String: Any] {
            if let instances = object["instances"] as? [String], let first = instances.first {
                return first
            }
            if let origins = object["origins"] as? [String], let first = origins.first {
                return first
            }
            if let location = object["location"] as? String {
                return location
            }
        }
        if let strings = endpoint as? [String] {
            return strings.first
        }
        return nil
    }

    static func buildCollectionsQueryBody(issuerDid: String, objectId: String) -> Data {
        let body: [String: Any] = [
            "requestId": UUID().uuidString,
            "target": issuerDid,
            "messages": [
                ["descriptor": [
                    "method": "CollectionsQuery",
                    "objectId": objectId,
                    "schema": "https://w3id.org/vc-status-list-2021/v1"
                ]]
            ]
        ]
        return (try? JSONSerialization.data(withJSONObject: body)) ?? Data()
    }

    /// Base64url-decodes an IdentityHub `data` field; returns `nil` unless it looks like a JWT (`eyJ`)
    /// or JSON (`{`).
    static func base64DecodeToString(_ encoded: String) -> String? {
        guard let data = Data(base64URLEncoded: encoded),
              let text = String(data: data, encoding: .utf8) else {
            return nil
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return (text.hasPrefix("eyJ") || trimmed.hasPrefix("{")) ? text : nil
    }

    /// Reads a query parameter from an opaque `did:` / `urn:` URL, whose `?...` lives in the
    /// scheme-specific part rather than a standard URL query.
    static func didURLQueryParameter(_ url: String, key: String) -> String? {
        guard let questionMark = url.firstIndex(of: "?") else { return nil }
        let afterQuestion = url[url.index(after: questionMark)...]
        let query = afterQuestion.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
            .first.map(String.init) ?? String(afterQuestion)

        for pair in query.split(separator: "&") {
            let components = pair.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false).map(String.init)
            let rawKey = components.first ?? ""
            if (rawKey.removingPercentEncoding ?? rawKey) == key {
                let rawValue = components.count > 1 ? components[1] : ""
                return rawValue.removingPercentEncoding ?? rawValue
            }
        }
        return nil
    }

    /// Resolves a DID document once, returning the typed model (for signature verification) and the raw
    /// `service` array (which preserves the IdentityHub `instances` endpoint the typed model omits).
    /// One fetch serves both, so the IdentityHub path verifies signatures without re-fetching.
    private func resolveDIDDocument(did: String) async -> (document: IdentifierDocument?, services: [[String: Any]]?) {
        guard let url = StatusCheckService.discoveryURL(for: did) else {
            configuration.logger.logVerbose(message: "StatusCheck: could not build a discovery URL to resolve the DID document.")
            return (nil, nil)
        }
        guard let data = try? await configuration.networking.fetch(url: url, StatusListCredentialFetchOperation.self) else {
            configuration.logger.logVerbose(message: "StatusCheck: failed to fetch the DID document from the discovery service.")
            return (nil, nil)
        }

        let document = try? JSONDecoder().decode(DiscoveryServiceResponse.self, from: data).didDocument

        var services: [[String: Any]]?
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let didDocument = (json["didDocument"] as? [String: Any]) ?? json
            services = didDocument["service"] as? [[String: Any]]
        }
        return (document, services)
    }

    /// Convenience over `resolveDIDDocument` for callers that only need the raw service array.
    private func resolveDIDDocumentServices(did: String) async -> [[String: Any]]? {
        return await resolveDIDDocument(did: did).services
    }

    private static func discoveryURL(for did: String) -> URL? {
        guard var components = URLComponents(string: VCSDKConfiguration.sharedInstance.discoveryUrl) else {
            return nil
        }
        let suffix = components.path.hasSuffix("/") ? did : "/" + did
        components.path = components.path + suffix
        return components.url
    }

    private static func compactJws(from data: Data) -> String? {
        guard let body = String(data: data, encoding: .utf8) else {
            return nil
        }
        let trimSet = CharacterSet(charactersIn: "\"").union(.whitespacesAndNewlines)
        let trimmed = body.trimmingCharacters(in: trimSet)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func jsonPayload(ofCompactJws jws: String) -> [String: Any]? {
        let segments = jws.components(separatedBy: ".")
        guard segments.count >= 2,
              let payloadData = Data(base64URLEncoded: segments[1]),
              let json = try? JSONSerialization.jsonObject(with: payloadData),
              let payload = json as? [String: Any] else {
            return nil
        }
        return payload
    }
}
