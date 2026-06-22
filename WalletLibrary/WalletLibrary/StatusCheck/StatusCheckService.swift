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

    func checkStatus(of verifiedId: VerifiedId) async -> VerifiedIdStatus {
        if let expiresOn = verifiedId.expiresOn, expiresOn < dateProvider() {
            return .expired
        }

        guard let credential = verifiedId as? VCVerifiedId else {
            return .noStatusEndpoint
        }

        guard let descriptor = StatusCheckService.parseCredentialStatus(from: credential.raw) else {
            return .noStatusEndpoint
        }

        let issuerDid = credential.raw.content.iss ?? ""
        return await fetchAndCheckStatusList(descriptor: descriptor, issuerDid: issuerDid)
    }

    private func fetchAndCheckStatusList(descriptor: CredentialStatusDescriptor,
                                         issuerDid: String) async -> VerifiedIdStatus {
        let statusListCredential = descriptor.effectiveStatusListCredential

        if let url = await resolveStatusListURL(statusListCredential) {
            return await checkDirectStatusList(url: url, descriptor: descriptor, issuerDid: issuerDid)
        }

        if statusListCredential.hasPrefix("did:") || descriptor.id.hasPrefix("urn:uuid:") {
            guard !issuerDid.isEmpty else { return .unknown }
            return await checkStatusViaIdentityHub(descriptor: descriptor, issuerDid: issuerDid)
        }

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
                return .unknown
            }
            return StatusCheckService.evaluate(statusList: statusList,
                                               descriptor: descriptor,
                                               bitIndex: descriptor.effectiveStatusListIndex)
        } catch {
            return .unknown
        }
    }

    /// Resolves the status list credential to a fetchable HTTPS URL: a direct `https://` URL, or a
    /// `did:web:` reference resolved through its DID document's service endpoint. Returns `nil` for
    /// anything else (caller falls back to the IdentityHub path).
    private func resolveStatusListURL(_ raw: String) async -> URL? {
        if raw.hasPrefix("https://") {
            return StatusCheckService.isWellFormedHttpsURL(raw) ? URL(string: raw) : nil
        }
        if raw.hasPrefix("did:web:") {
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

        guard let services = await resolveDIDDocumentServices(did: issuerDid),
              let hubService = StatusCheckService.findService(services, named: "IdentityHub"),
              let hubEndpoint = StatusCheckService.serviceEndpointURL(from: hubService),
              let hubURL = URL(string: hubEndpoint) else {
            return .unknown
        }

        do {
            let requestBody = StatusCheckService.buildCollectionsQueryBody(issuerDid: issuerDid, objectId: objectId)
            let responseData = try await configuration.networking.post(requestBody: requestBody,
                                                                       url: hubURL,
                                                                       CollectionsQueryPostOperation.self)
            guard let responseBody = String(data: responseData, encoding: .utf8) else {
                return .unknown
            }

            var statusList = await verifyAndExtractStatusList(fromJws: responseBody, issuerDid: issuerDid)
            if statusList == nil {
                statusList = await extractStatusListFromCollectionsResponse(responseBody, issuerDid: issuerDid)
            }

            guard let resolved = statusList else {
                return .unknown
            }
            return StatusCheckService.evaluate(statusList: resolved, descriptor: descriptor, bitIndex: bitIndex)
        } catch {
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

        let statusCredential = descriptor.effectiveStatusListCredential
        if statusCredential.hasPrefix("did:") {
            guard let encodedQueries = StatusCheckService.didURLQueryParameter(statusCredential, key: "queries"),
                  let decoded = Data(base64URLEncoded: encodedQueries),
                  let array = try? JSONSerialization.jsonObject(with: decoded) as? [[String: Any]],
                  let objectId = array.first?["objectId"] as? String else {
                return nil
            }
            return objectId
        }
        return nil
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
                                                          issuerDid: String) async -> (encodedList: String, statusPurpose: String)? {
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
                   let result = await verifyAndExtractStatusList(fromJws: decoded, issuerDid: issuerDid) {
                    return result
                }
                if let result = await verifyAndExtractStatusList(fromJws: entryData, issuerDid: issuerDid) {
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
                                            issuerDid: String) async -> (encodedList: String, statusPurpose: String)? {
        guard let token = JwsToken<StatusListClaims>(from: jws) else {
            return nil
        }
        do {
            try await validator.validate(token, expectedIssuerDid: issuerDid, now: dateProvider())
        } catch {
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
        return statusList.statusPurpose == "suspension" ? .suspended : .revoked
    }

    /// Parses the credential's own `credentialStatus` entry from the raw VC payload. The decoded
    /// `VerifiableCredentialDescriptor` only carries `id` / `type`, so the richer status-list fields
    /// are read straight from the token payload here.
    static func parseCredentialStatus(from raw: VerifiableCredential) -> CredentialStatusDescriptor? {
        guard let compact = raw.rawValue ?? (try? raw.serialize()),
              let payload = jsonPayload(ofCompactJws: compact),
              let vc = payload["vc"] as? [String: Any] else {
            return nil
        }

        let statusEntry: [String: Any]?
        if let object = vc["credentialStatus"] as? [String: Any] {
            statusEntry = object
        } else if let array = vc["credentialStatus"] as? [[String: Any]] {
            statusEntry = array.first
        } else {
            statusEntry = nil
        }

        guard let entry = statusEntry else {
            return nil
        }
        return CredentialStatusDescriptor(json: entry)
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

        let statusPurpose = subject["statusPurpose"] as? String ?? "revocation"
        return (encodedList, statusPurpose)
    }

    /// Reads the bit at [index] using least-significant-bit-first ordering (index 0 = LSB of byte 0),
    /// i.e. `1 << (index % 8)`. This matches Entra's status list encoding; MSB-first ordering would
    /// break revocation detection for any index that is not a multiple of 8.
    ///
    /// Returns `true` if the bit is set (revoked/suspended), `false` if clear (valid), or `nil` when
    /// [index] is outside the bitstring (caller treats as `.unknown`).
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

    private func resolveDIDDocumentServices(did: String) async -> [[String: Any]]? {
        guard let url = StatusCheckService.discoveryURL(for: did),
              let data = try? await configuration.networking.fetch(url: url, StatusListCredentialFetchOperation.self),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        let didDocument = (json["didDocument"] as? [String: Any]) ?? json
        return didDocument["service"] as? [[String: Any]]
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
