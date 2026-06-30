/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import Testing
@testable import WalletLibrary

/// Tests for the deterministic, network-free surface of `StatusCheckService`: bit reading, status
/// list evaluation, GZIP inflation, and the DID/service-endpoint parsing helpers.
struct StatusCheckServiceTests {

    // A status list bitstring whose only set bit is index 5 (least-significant-bit-first within
    // byte 0): 0b0010_0000. Byte 1 is empty, so indices 8...15 are all clear.
    private static let bitstring = Data([0x20, 0x00])

    // GZIP of `bitstring`, base64url-encoded — the form an `encodedList` arrives in.
    private static let encodedList = "H4sIAAAAAAAC_1NgAABdNl3UAgAAAA"

    // The same GZIP stream as raw bytes (canonical header, no FNAME).
    private static let gzipBytes = Data([
        0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff,
        0x53, 0x60, 0x00, 0x00, 0x5d, 0x36, 0x5d, 0xd4, 0x02, 0x00, 0x00, 0x00
    ])

    // A GZIP stream of `bitstring` that sets the FNAME flag ("name.bin\0"), exercising the
    // optional-field skipping in `gunzipped()`.
    private static let gzipBytesWithName = Data([
        0x1f, 0x8b, 0x08, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff,
        0x6e, 0x61, 0x6d, 0x65, 0x2e, 0x62, 0x69, 0x6e, 0x00,
        0x53, 0x60, 0x00, 0x00, 0x5d, 0x36, 0x5d, 0xd4, 0x02, 0x00, 0x00, 0x00
    ])

    // MARK: - checkBit

    @Test func checkBit_readsLeastSignificantBitFirst() {
        #expect(StatusCheckService.checkBit(Self.bitstring, index: 5) == true)
        #expect(StatusCheckService.checkBit(Self.bitstring, index: 0) == false)
        #expect(StatusCheckService.checkBit(Self.bitstring, index: 4) == false)
        #expect(StatusCheckService.checkBit(Self.bitstring, index: 6) == false)
        #expect(StatusCheckService.checkBit(Self.bitstring, index: 13) == false)
    }

    @Test func checkBit_indexOutsideBitstring_returnsNil() {
        #expect(StatusCheckService.checkBit(Self.bitstring, index: 16) == nil)
        #expect(StatusCheckService.checkBit(Self.bitstring, index: -1) == nil)
    }

    // MARK: - GZIP inflation

    @Test func gunzip_basicStream_roundTrips() {
        #expect(Self.gzipBytes.gunzipped() == Self.bitstring)
    }

    @Test func gunzip_streamWithFileNameFlag_roundTrips() {
        #expect(Self.gzipBytesWithName.gunzipped() == Self.bitstring)
    }

    @Test func gunzip_nonGzipInput_returnsNil() {
        #expect(Data([0x00, 0x01, 0x02, 0x03]).gunzipped() == nil)
        #expect(Data().gunzipped() == nil)
    }

    // MARK: - evaluate

    @Test func evaluate_bitClear_isValid() {
        let descriptor = makeDescriptor(statusPurpose: "")
        let result = StatusCheckService.evaluate(statusList: (Self.encodedList, "revocation"),
                                                 descriptor: descriptor,
                                                 bitIndex: 0)
        #expect(result == .valid)
    }

    @Test func evaluate_bitSetForRevocation_isRevoked() {
        let descriptor = makeDescriptor(statusPurpose: "revocation")
        let result = StatusCheckService.evaluate(statusList: (Self.encodedList, "revocation"),
                                                 descriptor: descriptor,
                                                 bitIndex: 5)
        #expect(result == .revoked)
    }

    @Test func evaluate_bitSetForSuspension_isSuspended() {
        let descriptor = makeDescriptor(statusPurpose: "suspension")
        let result = StatusCheckService.evaluate(statusList: (Self.encodedList, "suspension"),
                                                 descriptor: descriptor,
                                                 bitIndex: 5)
        #expect(result == .suspended)
    }

    @Test func evaluate_purposeMismatch_isUnknown() {
        let descriptor = makeDescriptor(statusPurpose: "revocation")
        let result = StatusCheckService.evaluate(statusList: (Self.encodedList, "suspension"),
                                                 descriptor: descriptor,
                                                 bitIndex: 5)
        #expect(result == .unknown)
    }

    @Test func evaluate_undecodableList_isUnknown() {
        let descriptor = makeDescriptor(statusPurpose: "revocation")
        let result = StatusCheckService.evaluate(statusList: ("not-a-valid-gzip", "revocation"),
                                                 descriptor: descriptor,
                                                 bitIndex: 5)
        #expect(result == .unknown)
    }

    // MARK: - isWellFormedHttpsURL

    @Test func isWellFormedHttpsURL_acceptsHttpsWithHost() {
        #expect(StatusCheckService.isWellFormedHttpsURL("https://example.com/status/list") == true)
    }

    @Test func isWellFormedHttpsURL_rejectsNonHttpsOrHostless() {
        #expect(StatusCheckService.isWellFormedHttpsURL("http://example.com") == false)
        #expect(StatusCheckService.isWellFormedHttpsURL("https://") == false)
        #expect(StatusCheckService.isWellFormedHttpsURL("ftp://example.com") == false)
        #expect(StatusCheckService.isWellFormedHttpsURL("not a url") == false)
    }

    // MARK: - findService

    @Test func findService_matchesByType() {
        let services: [[String: Any]] = [["type": "IdentityHub", "serviceEndpoint": "https://hub"]]
        #expect(StatusCheckService.findService(services, named: "IdentityHub") != nil)
    }

    @Test func findService_matchesByFragmentId() {
        let services: [[String: Any]] = [["id": "did:web:issuer#IdentityHub", "serviceEndpoint": "https://hub"]]
        #expect(StatusCheckService.findService(services, named: "IdentityHub") != nil)
    }

    @Test func findService_noMatch_returnsNil() {
        let services: [[String: Any]] = [["type": "LinkedDomains", "serviceEndpoint": "https://ld"]]
        #expect(StatusCheckService.findService(services, named: "IdentityHub") == nil)
    }

    // MARK: - serviceEndpointURL

    @Test func serviceEndpointURL_bareString() {
        #expect(StatusCheckService.serviceEndpointURL(from: ["serviceEndpoint": "https://hub"]) == "https://hub")
    }

    @Test func serviceEndpointURL_identityHubInstances() {
        let service: [String: Any] = ["serviceEndpoint": ["instances": ["https://hub1", "https://hub2"]]]
        #expect(StatusCheckService.serviceEndpointURL(from: service) == "https://hub1")
    }

    @Test func serviceEndpointURL_linkedDomainsOrigins() {
        let service: [String: Any] = ["serviceEndpoint": ["origins": ["https://origin1"]]]
        #expect(StatusCheckService.serviceEndpointURL(from: service) == "https://origin1")
    }

    @Test func serviceEndpointURL_locationObject() {
        let service: [String: Any] = ["serviceEndpoint": ["location": "https://loc"]]
        #expect(StatusCheckService.serviceEndpointURL(from: service) == "https://loc")
    }

    @Test func serviceEndpointURL_array() {
        let service: [String: Any] = ["serviceEndpoint": ["https://first", "https://second"]]
        #expect(StatusCheckService.serviceEndpointURL(from: service) == "https://first")
    }

    @Test func serviceEndpointURL_missing_returnsNil() {
        #expect(StatusCheckService.serviceEndpointURL(from: ["type": "IdentityHub"]) == nil)
    }

    // MARK: - didURLQueryParameter

    @Test func didURLQueryParameter_extractsNamedValue() {
        let url = "did:web:example.com?service=IdentityHub&queries=YWJj"
        #expect(StatusCheckService.didURLQueryParameter(url, key: "queries") == "YWJj")
        #expect(StatusCheckService.didURLQueryParameter(url, key: "service") == "IdentityHub")
    }

    @Test func didURLQueryParameter_stopsAtFragment() {
        let url = "did:ion:abc?queries=eyJ0ZXN0Ijox#fragment"
        #expect(StatusCheckService.didURLQueryParameter(url, key: "queries") == "eyJ0ZXN0Ijox")
    }

    @Test func didURLQueryParameter_missing_returnsNil() {
        #expect(StatusCheckService.didURLQueryParameter("did:web:example.com", key: "queries") == nil)
    }

    // MARK: - buildCollectionsQueryBody

    @Test func buildCollectionsQueryBody_buildsValidCollectionsQuery() throws {
        let body = StatusCheckService.buildCollectionsQueryBody(issuerDid: "did:web:issuer", objectId: "object-123")
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])

        #expect(json["target"] as? String == "did:web:issuer")
        let messages = try #require(json["messages"] as? [[String: Any]])
        let descriptor = try #require(messages.first?["descriptor"] as? [String: Any])
        #expect(descriptor["method"] as? String == "CollectionsQuery")
        #expect(descriptor["objectId"] as? String == "object-123")
        #expect(descriptor["schema"] as? String == "https://w3id.org/vc-status-list-2021/v1")
    }

    // MARK: - Helpers

    private func makeDescriptor(statusPurpose: String) -> CredentialStatusDescriptor {
        let descriptor = CredentialStatusDescriptor(json: ["id": "urn:uuid:test", "statusPurpose": statusPurpose])
        return descriptor!
    }
}

/// Tests for `CredentialStatusDescriptor`'s normalisation across the StatusList2021 /
/// RevocationList2021 / RevocationList2020 credential-status type variants.
struct CredentialStatusDescriptorTests {

    @Test func statusList2021Entry_normalisesCredentialAndIndex() {
        let descriptor = CredentialStatusDescriptor(json: [
            "id": "urn:uuid:abc",
            "type": "StatusList2021Entry",
            "statusPurpose": "revocation",
            "statusListIndex": 5,
            "statusListCredential": "https://issuer/status/list"
        ])
        #expect(descriptor?.effectiveStatusListCredential == "https://issuer/status/list")
        #expect(descriptor?.effectiveStatusListIndex == 5)
    }

    @Test func revocationList2020_normalisesViaRevocationFields() {
        let descriptor = CredentialStatusDescriptor(json: [
            "id": "urn:uuid:def",
            "type": "RevocationList2020Status",
            "revocationListIndex": 7,
            "revocationListCredential": "https://issuer/revocation/list"
        ])
        #expect(descriptor?.effectiveStatusListCredential == "https://issuer/revocation/list")
        #expect(descriptor?.effectiveStatusListIndex == 7)
    }

    @Test func numericStringIndex_isParsed() {
        let descriptor = CredentialStatusDescriptor(json: [
            "id": "urn:uuid:ghi",
            "statusListIndex": "9",
            "statusListCredential": "https://issuer/status/list"
        ])
        #expect(descriptor?.effectiveStatusListIndex == 9)
    }

    @Test func emptyStringCredential_isTreatedAsAbsent() {
        let descriptor = CredentialStatusDescriptor(json: [
            "id": "urn:uuid:jkl",
            "statusListCredential": "",
            "revocationListIndex": 3,
            "revocationListCredential": "https://issuer/revocation/list"
        ])
        #expect(descriptor?.statusListCredential == nil)
        #expect(descriptor?.effectiveStatusListCredential == "https://issuer/revocation/list")
        #expect(descriptor?.effectiveStatusListIndex == 3)
    }

    @Test func noCredentialAndNoId_returnsNil() {
        let descriptor = CredentialStatusDescriptor(json: ["statusPurpose": "revocation"])
        #expect(descriptor == nil)
    }

    @Test func idWithoutCredential_isRetainedForIdentityHubLookup() {
        let descriptor = CredentialStatusDescriptor(json: ["id": "urn:uuid:mno"])
        #expect(descriptor != nil)
        #expect(descriptor?.effectiveStatusListCredential == nil)
    }
}

/// Tests for `StatusListTokenValidator`: issuer binding, signature verification, expiry, and reuse of
/// a pre-resolved DID document (so the IdentityHub path does not fetch it twice).
struct StatusListTokenValidatorTests {

    private let issuer = "did:web:issuer.example"

    @Test func emptyExpectedIssuer_throwsEmptyIssuer() async {
        let validator = makeValidator(verifies: true)
        let token = makeToken(keyId: "\(issuer)#key-1", issuer: issuer, expiry: nil)
        await #expect(throws: StatusListValidationError.emptyIssuer) {
            try await validator.validate(token, expectedIssuerDid: "", now: Date())
        }
    }

    @Test func missingKeyId_throwsMissingKeyId() async {
        let validator = makeValidator(verifies: true)
        let token = makeToken(keyId: nil, issuer: issuer, expiry: nil)
        await #expect(throws: StatusListValidationError.missingKeyId) {
            try await validator.validate(token, expectedIssuerDid: issuer, now: Date())
        }
    }

    @Test func signerDidNotIssuer_throwsIssuerMismatch() async {
        let validator = makeValidator(verifies: true)
        let token = makeToken(keyId: "did:web:attacker#key-1", issuer: "did:web:attacker", expiry: nil)
        await #expect(throws: StatusListValidationError.issuerMismatch) {
            try await validator.validate(token, expectedIssuerDid: issuer, now: Date())
        }
    }

    @Test func validSignatureWithFutureExpiry_succeedsWithoutResolving() async throws {
        // The resolver throws if hit; a passing validation proves the pre-resolved document was reused.
        let validator = makeValidator(verifies: true)
        let futureExpiry = Int(Date().timeIntervalSince1970) + 10_000
        let token = makeToken(keyId: "\(issuer)#key-1", issuer: issuer, expiry: futureExpiry)
        try await validator.validate(token,
                                     expectedIssuerDid: issuer,
                                     now: Date(),
                                     preResolvedDocument: makeDocument(keyId: "#key-1"))
    }

    @Test func missingExpiry_throwsMissingExpiry() async {
        let validator = makeValidator(verifies: true)
        let token = makeToken(keyId: "\(issuer)#key-1", issuer: issuer, expiry: nil)
        await #expect(throws: StatusListValidationError.missingExpiry) {
            try await validator.validate(token,
                                         expectedIssuerDid: issuer,
                                         now: Date(),
                                         preResolvedDocument: makeDocument(keyId: "#key-1"))
        }
    }

    @Test func notYetValidToken_throwsNotYetValid() async {
        let validator = makeValidator(verifies: true)
        let futureExpiry = Int(Date().timeIntervalSince1970) + 10_000
        let futureNotBefore = Int(Date().timeIntervalSince1970) + 5_000
        let token = makeToken(keyId: "\(issuer)#key-1", issuer: issuer, expiry: futureExpiry, notBefore: futureNotBefore)
        await #expect(throws: StatusListValidationError.notYetValid) {
            try await validator.validate(token,
                                         expectedIssuerDid: issuer,
                                         now: Date(),
                                         preResolvedDocument: makeDocument(keyId: "#key-1"))
        }
    }

    @Test func signatureVerifiesOnlyKidReferencedKey_notAnyKey() async {
        // The kid-referenced key (#key-1) is absent from the document — only an unrelated #key-2 is
        // present. Tight binding means we do NOT fall back to trying #key-2, so this fails.
        let validator = makeValidator(verifies: true)
        let futureExpiry = Int(Date().timeIntervalSince1970) + 10_000
        let token = makeToken(keyId: "\(issuer)#key-1", issuer: issuer, expiry: futureExpiry)
        await #expect(throws: StatusListValidationError.invalidSignature) {
            try await validator.validate(token,
                                         expectedIssuerDid: issuer,
                                         now: Date(),
                                         preResolvedDocument: makeDocument(keyId: "#key-2"))
        }
    }

    @Test func invalidSignature_throwsInvalidSignature() async {
        let validator = makeValidator(verifies: false)
        let token = makeToken(keyId: "\(issuer)#key-1", issuer: issuer, expiry: nil)
        await #expect(throws: StatusListValidationError.invalidSignature) {
            try await validator.validate(token,
                                         expectedIssuerDid: issuer,
                                         now: Date(),
                                         preResolvedDocument: makeDocument(keyId: "#key-1"))
        }
    }

    @Test func expiredToken_throwsExpired() async {
        let validator = makeValidator(verifies: true)
        let pastExpiry = Int(Date().timeIntervalSince1970) - 10_000
        let token = makeToken(keyId: "\(issuer)#key-1", issuer: issuer, expiry: pastExpiry)
        await #expect(throws: StatusListValidationError.expired) {
            try await validator.validate(token,
                                         expectedIssuerDid: issuer,
                                         now: Date(),
                                         preResolvedDocument: makeDocument(keyId: "#key-1"))
        }
    }

    // MARK: - Helpers

    private func makeValidator(verifies: Bool) -> StatusListTokenValidator {
        StatusListTokenValidator(didResolver: ThrowingDiscoveryNetworking(),
                                 tokenVerifier: StubTokenVerifier(result: verifies))
    }

    private func makeToken(keyId: String?, issuer: String?, expiry: Int?, notBefore: Int? = nil) -> JwsToken<StatusListClaims> {
        let header = Header(keyId: keyId)
        let claims = StatusListClaims(iss: issuer, exp: expiry, nbf: notBefore)
        return JwsToken(headers: header, content: claims)!
    }

    private func makeDocument(keyId: String) -> IdentifierDocument {
        let jwk = PublicJWK(x: "AAAA", y: "AAAA", keyType: "EC", keyId: keyId, algorithm: "ES256K", curve: "secp256k1")
        let key = IdentifierDocumentPublicKey(id: keyId,
                                              type: "EcdsaSecp256k1VerificationKey2019",
                                              controller: nil,
                                              publicKeyJwk: jwk,
                                              purposes: nil)
        return IdentifierDocument(service: nil, verificationMethod: [key], authentication: [], id: issuer)
    }
}

// MARK: - Test doubles

/// A `DiscoveryNetworking` that always throws, used to prove the validator does not fetch a DID
/// document when a pre-resolved one is supplied.
private struct ThrowingDiscoveryNetworking: DiscoveryNetworking {
    func getDocument(from identifier: String) async throws -> IdentifierDocument {
        throw StatusListValidationError.noPublicKeysInIdentifierDocument
    }
}

/// A `TokenVerifying` whose signature-verification result is fixed by the test.
private struct StubTokenVerifier: TokenVerifying {
    let result: Bool
    func verify<T>(token: JwsToken<T>, usingPublicKey key: JWK) throws -> Bool {
        return result
    }
}

/// End-to-end tests for `StatusCheckService.checkStatus(of:)`: expiry short-circuit, the
/// no-status-endpoint path, that OpenID4VCI credentials are inspected (not silently skipped), and
/// that every `credentialStatus` entry is evaluated so a suspension behind a clear revocation is caught.
struct StatusCheckServiceOrchestrationTests {

    private let helper = MockVerifiableCredentialHelper()
    private let issuer = "did:web:issuer.example"

    // GZIP+base64url of a bitstring with bit 5 set (flagged: revoked/suspended).
    private static let bitSetEncodedList = "H4sIAAAAAAAC_1NgAABdNl3UAgAAAA"
    // GZIP+base64url of an all-clear bitstring (valid).
    private static let bitClearEncodedList = "H4sIAAAAAAAC_2NgAAD_EtlBAgAAAA"

    private var futureUnixTime: Int { Int(Date().timeIntervalSince1970) + 100_000 }
    private var pastUnixTime: Int { Int(Date().timeIntervalSince1970) - 100_000 }

    @Test func expiredCredential_returnsExpired() async {
        let service = makeService(networking: ThrowingNetworking())
        let credential = makeVCVerifiedId(credentialStatus: nil, expiry: pastUnixTime)
        let status = await service.checkStatus(of: credential)
        #expect(status == .expired)
    }

    @Test func noCredentialStatus_returnsNoStatusEndpoint() async {
        let service = makeService(networking: ThrowingNetworking())
        let credential = makeVCVerifiedId(credentialStatus: nil, expiry: futureUnixTime)
        let status = await service.checkStatus(of: credential)
        #expect(status == .noStatusEndpoint)
    }

    @Test func openID4VCICredentialWithStatus_isInspectedNotSkipped() async throws {
        // Regression guard: the cast is to `InternalVerifiedId`, so an OpenID4VCI credential carrying a
        // status endpoint is inspected. The fetch throws, so the result is the indeterminate `.unknown`
        // — never `.noStatusEndpoint`, which a caller could read as "nothing to check, accept it".
        let service = makeService(networking: ThrowingNetworking())
        let credential = try makeOpenID4VCIVerifiedId(statusListCredential: "https://issuer.example/status/1",
                                                      expiry: futureUnixTime)
        let status = await service.checkStatus(of: credential)
        #expect(status == .unknown)
    }

    @Test func directHttpsRevocationBitSet_returnsRevoked() async {
        let listURL = "https://issuer.example/revocation/1"
        let networking = MapNetworking(bodies: [listURL: statusListJws(encodedList: Self.bitSetEncodedList,
                                                                       statusPurpose: "revocation")])
        let service = makeService(networking: networking, validator: AcceptingValidator())
        let credential = makeVCVerifiedId(credentialStatus: [statusEntry(listURL: listURL, index: 5, purpose: "revocation")],
                                          expiry: futureUnixTime)
        let status = await service.checkStatus(of: credential)
        #expect(status == .revoked)
    }

    @Test func multipleEntries_suspensionBehindClearRevocation_returnsSuspended() async {
        // Revocation bit clear, suspension bit set. Evaluating only the first entry would report
        // `.valid`; checking every entry surfaces the suspension.
        let revocationURL = "https://issuer.example/revocation/1"
        let suspensionURL = "https://issuer.example/suspension/1"
        let networking = MapNetworking(bodies: [
            revocationURL: statusListJws(encodedList: Self.bitClearEncodedList, statusPurpose: "revocation"),
            suspensionURL: statusListJws(encodedList: Self.bitSetEncodedList, statusPurpose: "suspension")
        ])
        let service = makeService(networking: networking, validator: AcceptingValidator())
        let credential = makeVCVerifiedId(credentialStatus: [
            statusEntry(listURL: revocationURL, index: 5, purpose: "revocation"),
            statusEntry(listURL: suspensionURL, index: 5, purpose: "suspension")
        ], expiry: futureUnixTime)
        let status = await service.checkStatus(of: credential)
        #expect(status == .suspended)
    }

    // MARK: - Fixtures

    private func makeService(networking: LibraryNetworking,
                             validator: StatusListTokenValidator? = nil) -> StatusCheckService {
        StatusCheckService(configuration: LibraryConfiguration(networking: networking),
                           validator: validator)
    }

    private func statusEntry(listURL: String, index: Int, purpose: String) -> [String: Any] {
        ["id": "urn:uuid:\(purpose)",
         "type": "StatusList2021Entry",
         "statusListCredential": listURL,
         "statusListIndex": index,
         "statusPurpose": purpose]
    }

    /// Builds a `VCVerifiedId` whose `raw.rawValue` carries the given `credentialStatus` (single object
    /// when one entry, array when several). Using the raw-value initializer sidesteps typed decoding,
    /// which models `credentialStatus` as a single object and so can't represent the array form.
    private func makeVCVerifiedId(credentialStatus: [[String: Any]]?, expiry: Int) -> VCVerifiedId {
        var vc: [String: Any] = [
            "@context": ["https://www.w3.org/2018/credentials/v1"],
            "type": ["VerifiableCredential"],
            "credentialSubject": ["name": "test"]
        ]
        if let credentialStatus {
            vc["credentialStatus"] = credentialStatus.count == 1 ? credentialStatus[0] : credentialStatus
        }
        let payload: [String: Any] = ["jti": "urn:vc:test", "iss": issuer, "iat": 0, "exp": expiry, "vc": vc]
        let content = VCClaims(jti: "urn:vc:test", iss: issuer, sub: "", iat: 0, exp: expiry, vc: nil)
        let raw = VerifiableCredential(headers: Header(), content: content, rawValue: Self.compactJws(payload))!
        return try! VCVerifiedId(raw: raw, from: helper.createMockContract())
    }

    private func makeOpenID4VCIVerifiedId(statusListCredential: String, expiry: Int) throws -> OpenID4VCIVerifiedId {
        let vc: [String: Any] = [
            "@context": ["https://www.w3.org/2018/credentials/v1"],
            "type": ["VerifiableCredential"],
            "credentialSubject": ["name": "test"],
            "credentialStatus": ["id": "urn:uuid:status",
                                 "type": "StatusList2021Entry",
                                 "statusListCredential": statusListCredential,
                                 "statusListIndex": "3",
                                 "statusPurpose": "revocation"]
        ]
        let payload: [String: Any] = ["jti": "urn:vc:openid", "iss": issuer, "iat": 0, "exp": expiry, "vc": vc]
        let config = CredentialConfiguration(format: nil,
                                             scope: nil,
                                             cryptographic_binding_methods_supported: nil,
                                             cryptographic_suites_supported: nil,
                                             credential_definition: nil,
                                             display: nil,
                                             proof_types_supported: nil)
        return try OpenID4VCIVerifiedId(raw: Self.compactJws(payload),
                                        issuerName: "Test Issuer",
                                        configuration: config)
    }

    private func statusListJws(encodedList: String, statusPurpose: String) -> Data {
        let payload: [String: Any] = [
            "iss": issuer,
            "vc": ["credentialSubject": ["encodedList": encodedList, "statusPurpose": statusPurpose]]
        ]
        return Data(Self.compactJws(payload).utf8)
    }

    private static func compactJws(_ payload: [String: Any]) -> String {
        let header = base64URL(try! JSONSerialization.data(withJSONObject: ["alg": "ES256K", "typ": "JWT"]))
        let body = base64URL(try! JSONSerialization.data(withJSONObject: payload))
        return "\(header).\(body).AAAA"
    }

    private static func base64URL(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

/// A `LibraryNetworking` returning canned response bodies keyed by URL; unmapped requests throw.
private struct MapNetworking: LibraryNetworking {
    let bodies: [String: Data]
    func resetCorrelationHeader() {}
    func fetch<Operation: WalletLibraryFetchOperation>(url: URL,
                                                       _ type: Operation.Type,
                                                       additionalHeaders: [String: String]?) async throws -> Operation.ResponseBody {
        guard let data = bodies[url.absoluteString], let body = data as? Operation.ResponseBody else {
            throw StatusListValidationError.noPublicKeysInIdentifierDocument
        }
        return body
    }
    func post<Operation: WalletLibraryPostOperation>(requestBody: Operation.RequestBody,
                                                     url: URL,
                                                     _ type: Operation.Type,
                                                     additionalHeaders: [String: String]?) async throws -> Operation.ResponseBody {
        throw StatusListValidationError.noPublicKeysInIdentifierDocument
    }
}

/// A `LibraryNetworking` that throws on every request, proving a credential is still inspected even
/// when its status list can't be fetched.
private struct ThrowingNetworking: LibraryNetworking {
    func resetCorrelationHeader() {}
    func fetch<Operation: WalletLibraryFetchOperation>(url: URL,
                                                       _ type: Operation.Type,
                                                       additionalHeaders: [String: String]?) async throws -> Operation.ResponseBody {
        throw StatusListValidationError.noPublicKeysInIdentifierDocument
    }
    func post<Operation: WalletLibraryPostOperation>(requestBody: Operation.RequestBody,
                                                     url: URL,
                                                     _ type: Operation.Type,
                                                     additionalHeaders: [String: String]?) async throws -> Operation.ResponseBody {
        throw StatusListValidationError.noPublicKeysInIdentifierDocument
    }
}

/// A validator that accepts every token, isolating the orchestration tests from signature and
/// freshness checks (covered by `StatusListTokenValidatorTests`).
private final class AcceptingValidator: StatusListTokenValidator {
    init() { super.init(didResolver: ThrowingDiscoveryNetworking()) }
    override func validate(_ token: JwsToken<StatusListClaims>,
                           expectedIssuerDid: String,
                           now: Date,
                           preResolvedDocument: IdentifierDocument?) async throws {
        // Accept: bits are trusted for these orchestration tests.
    }
}
