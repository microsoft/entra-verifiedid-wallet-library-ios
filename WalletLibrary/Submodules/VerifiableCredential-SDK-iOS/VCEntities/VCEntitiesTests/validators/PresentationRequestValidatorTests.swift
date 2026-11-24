/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationRequestValidatorTests: XCTestCase {
    
    let verifier: TokenVerifying = MockTokenVerifier(isTokenValid: true)
    let mockPublicKey = PublicJWK(x: "x",
                                  y: "y",
                                  keyType: "EC",
                                  keyId: "keyId",
                                  algorithm: "mockAlgorithm",
                                  curve: "mockCurve")
    var mockDidPublicKey: IdentifierDocumentPublicKey!
    
    override func setUpWithError() throws {
        mockDidPublicKey = IdentifierDocumentPublicKey(id: "#keyId",
                                                       type: "Typetest",
                                                       controller: "did:test",
                                                       publicKeyJwk: mockPublicKey,
                                                       purposes: ["purpose"])
    }
    
    override func tearDownWithError() throws {
        MockTokenVerifier.wasVerifyCalled = false
    }
    
    func testShouldBeValid() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let mockRequestClaims = createMockPresentationRequestClaims()
        if let mockRequest = PresentationRequestToken(headers: Header(keyId: "did:test#keyId"),content: mockRequestClaims) {
            try validator.validate(request: mockRequest, usingKeys: [mockDidPublicKey])
            XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
        }
    }

    func testAbsoluteKeyIdForRequestedDidShouldBeValid() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let key = IdentifierDocumentPublicKey(id: "did:test#keyId",
                                              type: "Typetest",
                                              controller: "did:test",
                                              publicKeyJwk: mockPublicKey,
                                              purposes: ["purpose"])
        let mockRequestClaims = createMockPresentationRequestClaims()
        let request = PresentationRequestToken(
            headers: Header(keyId: "did:test#keyId"),
            content: mockRequestClaims)!

        try validator.validate(request: request, usingKeys: [key])

        XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
    }

    func testAbsoluteKeyIdForDifferentDidIsRejected() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let key = IdentifierDocumentPublicKey(id: "did:test:attacker#keyId",
                                              type: "Typetest",
                                              controller: "did:test:attacker",
                                              publicKeyJwk: mockPublicKey,
                                              purposes: ["purpose"])
        let mockRequestClaims = createMockPresentationRequestClaims()
        let request = PresentationRequestToken(
            headers: Header(keyId: "did:test#keyId"),
            content: mockRequestClaims)!

        XCTAssertThrowsError(try validator.validate(request: request, usingKeys: [key])) { error in
            XCTAssertEqual(error as? PresentationRequestValidatorError,
                           PresentationRequestValidatorError.invalidSignature)
        }
        XCTAssertFalse(MockTokenVerifier.wasVerifyCalled)
    }

    func testKeyIdWithMultipleFragmentsIsMalformed() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let mockRequestClaims = createMockPresentationRequestClaims()
        let request = PresentationRequestToken(
            headers: Header(keyId: "did:test#keyId#other"),
            content: mockRequestClaims)!

        XCTAssertThrowsError(try validator.validate(request: request, usingKeys: [mockDidPublicKey])) { error in
            XCTAssertEqual(error as? PresentationRequestValidatorError,
                           PresentationRequestValidatorError.keyIdInTokenHeaderMalformed)
        }
        XCTAssertFalse(MockTokenVerifier.wasVerifyCalled)
    }
    
    func testInvalidScopeValue() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let mockRequestClaims = createMockPresentationRequestClaims(scope: "wrongValue")
        if let mockRequest = PresentationRequestToken(headers: Header(keyId: "did:test#keyId"),content: mockRequestClaims) {
            XCTAssertThrowsError(try validator.validate(request: mockRequest, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, PresentationRequestValidatorError.invalidScopeValue)
            }
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testInvalidResponseTypeValue() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let mockRequestClaims = createMockPresentationRequestClaims(responseType: "wrongValue")
        if let mockRequest = PresentationRequestToken(headers: Header(keyId: "did:test#keyId"),content: mockRequestClaims) {
            XCTAssertThrowsError(try validator.validate(request: mockRequest, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, PresentationRequestValidatorError.invalidResponseTypeValue)
            }
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testInvalidResponseModeValue() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let mockRequestClaims = createMockPresentationRequestClaims(responseMode: "wrongValue")
        if let mockRequest = PresentationRequestToken(headers: Header(keyId: "did:test#keyId"),content: mockRequestClaims) {
            XCTAssertThrowsError(try validator.validate(request: mockRequest, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, PresentationRequestValidatorError.invalidResponseModeValue)
            }
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testExpiredTokenError() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let mockRequestClaims = createMockPresentationRequestClaims(timeConstraints: TokenTimeConstraints(expiryInSeconds: -500))
        if let mockRequest = PresentationRequestToken(headers: Header(keyId: "did:test#keyId"),content: mockRequestClaims) {
            XCTAssertThrowsError(try validator.validate(request: mockRequest, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, PresentationRequestValidatorError.tokenExpired)
            }
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testClockSkewLeewayForExpirationCheck() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let mockRequestClaims = createMockPresentationRequestClaims(timeConstraints: TokenTimeConstraints(expiryInSeconds: -200))
        if let mockRequest = PresentationRequestToken(headers: Header(keyId: "did:test#keyId"),content: mockRequestClaims) {
            try validator.validate(request: mockRequest, usingKeys: [mockDidPublicKey])
            XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testSubjectIdentifierTypeNotSupportedError() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let mockInvalidRegistration = PresentationRequestValidatorTests.createRegistration(expectedSubjectIdentifierType: "wrongValue")
        let mockRequestClaims = createMockPresentationRequestClaims(registration: mockInvalidRegistration)
        if let mockRequest = PresentationRequestToken(headers: Header(keyId: "did:test#keyId"),content: mockRequestClaims) {
            XCTAssertThrowsError(try validator.validate(request: mockRequest, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, PresentationRequestValidatorError.subjectIdentifierTypeNotSupported)
            }
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testSigningAlgorithmNotSupportedForVCError() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let mockInvalidRegistration = PresentationRequestValidatorTests.createRegistration(expectedSupportedAlgorithmForVC: "wrongValue")
        let mockRequestClaims = createMockPresentationRequestClaims(registration: mockInvalidRegistration)
        if let mockRequest = PresentationRequestToken(headers: Header(keyId: "did:test#keyId"),content: mockRequestClaims) {
            XCTAssertThrowsError(try validator.validate(request: mockRequest, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, PresentationRequestValidatorError.responseSigningAlgorithmNotSupportedForVCs)
            }
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }
    
    func testSigningAlgorithmNotSupportedForVPError() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        let mockInvalidRegistration = PresentationRequestValidatorTests.createRegistration(expectedSupportedAlgorithmForVP: "wrongValue")
        let mockRequestClaims = createMockPresentationRequestClaims(registration: mockInvalidRegistration)
        if let mockRequest = PresentationRequestToken(headers: Header(keyId: "did:test#keyId"),content: mockRequestClaims) {
            XCTAssertThrowsError(try validator.validate(request: mockRequest, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, PresentationRequestValidatorError.responseSigningAlgorithmNotSupportedForVPs)
            }
            XCTAssertTrue(!MockTokenVerifier.wasVerifyCalled)
        }
    }

    func testFipsRegistrationAcceptsConfiguredJwkHolder() throws {
        let registration = try JSONDecoder().decode(RegistrationClaims.self, from: Data("""
            {"subject_syntax_types_supported":["did:jwk"],
             "vp_formats":{"jwt_vp":{"alg":["ES256","ES384","ES512","EdDSA"]},
                           "jwt_vc":{"alg":["ES256","ES384","ES512","EdDSA"]}}}
            """.utf8))
        let validator = PresentationRequestValidator(
            verifier: verifier,
            responseCapabilities: [PresentationResponseCapability(method: "did:jwk", algorithm: "ES256")])
        let token = try XCTUnwrap(PresentationRequestToken(
            headers: Header(keyId: "did:test#keyId"),
            content: createMockPresentationRequestClaims(registration: registration)))
        let request = try XCTUnwrap(PresentationRequestToken(from: try token.serialize()))

        try validator.validate(request: request, usingKeys: [mockDidPublicKey])

        XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
    }

    func testLegacyAndMixedRegistrationPreserveAcceptanceAcrossHolderInventories() throws {
        let legacy = PresentationResponseCapability(method: "did:ion", algorithm: "ES256K")
        let fips = PresentationResponseCapability(method: "did:jwk", algorithm: "ES256")
        for methods in [["did:ion"], ["did:ion", "did:jwk"]] {
            for capabilities in [[], [legacy], [fips], [fips, legacy]] {
                let registration = capabilityRegistration(methods: methods, vpAlgorithms: ["ES256K"],
                                                          vcAlgorithms: ["ES256K"])
                let validator = PresentationRequestValidator(verifier: verifier, responseCapabilities: capabilities)
                let request = try XCTUnwrap(PresentationRequestToken(
                    headers: Header(keyId: "did:test#keyId"),
                    content: createMockPresentationRequestClaims(registration: registration)))
                try validator.validate(request: request, usingKeys: [mockDidPublicKey])
            }
        }
        XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
    }

    func testRejectsIncompatibleMethodAlgorithmPairsAndNoIntersection() throws {
        let cases: [([String], [String], [PresentationResponseCapability], PresentationRequestValidatorError)] = [
            (["did:ion"], ["ES256"], PresentationResponseCapability.supported, .responseSigningAlgorithmNotSupportedForVPs),
            (["did:jwk"], ["ES256K"], PresentationResponseCapability.supported, .responseSigningAlgorithmNotSupportedForVPs),
            (["did:jwk"], ["ES256"],
             [PresentationResponseCapability(method: "did:ion", algorithm: "ES256K")], .subjectIdentifierTypeNotSupported),
            (["did:jwk"], ["EdDSA", "ES384", "ES512"], PresentationResponseCapability.supported,
             .responseSigningAlgorithmNotSupportedForVPs),
            (["did:jwk"], ["ES256"], [], .subjectIdentifierTypeNotSupported),
            (["did:jwk"], ["ES384"],
             [PresentationResponseCapability(method: "did:jwk", algorithm: "ES384")], .subjectIdentifierTypeNotSupported),
            ([], ["ES256"], PresentationResponseCapability.supported, .subjectIdentifierTypeNotSupported),
            (["did:jwk"], [], PresentationResponseCapability.supported, .responseSigningAlgorithmNotSupportedForVPs)
        ]
        for (methods, algorithms, capabilities, expectedError) in cases {
            let validator = PresentationRequestValidator(verifier: verifier, responseCapabilities: capabilities)
            let registration = capabilityRegistration(methods: methods, vpAlgorithms: algorithms, vcAlgorithms: ["ES256"])
            let request = try XCTUnwrap(PresentationRequestToken(
                headers: Header(keyId: "did:test#keyId"),
                content: createMockPresentationRequestClaims(registration: registration)))
            XCTAssertThrowsError(try validator.validate(request: request, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, expectedError)
            }
        }
        XCTAssertFalse(MockTokenVerifier.wasVerifyCalled)
    }

    func testCredentialAlgorithmsAreIndependentOfHolderSigningAlgorithm() throws {
        for vcAlgorithms in [["ES256K"], ["EdDSA"], ["ES256"]] {
            let registration = capabilityRegistration(methods: ["did:jwk"], vpAlgorithms: ["ES256"],
                                                      vcAlgorithms: vcAlgorithms)
            let validator = PresentationRequestValidator(verifier: verifier)
            let request = try XCTUnwrap(PresentationRequestToken(
                headers: Header(keyId: "did:test#keyId"),
                content: createMockPresentationRequestClaims(registration: registration)))
            try validator.validate(request: request, usingKeys: [mockDidPublicKey])
        }
        for vcAlgorithms in [[], ["ES384", "ES512"], ["none"]] {
            let registration = capabilityRegistration(methods: ["did:jwk"], vpAlgorithms: ["ES256"],
                                                      vcAlgorithms: vcAlgorithms)
            let request = try XCTUnwrap(PresentationRequestToken(
                headers: Header(keyId: "did:test#keyId"),
                content: createMockPresentationRequestClaims(registration: registration)))
            XCTAssertThrowsError(try PresentationRequestValidator(verifier: verifier)
                .validate(request: request, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, .responseSigningAlgorithmNotSupportedForVCs)
            }
        }
    }

    func testOmittedRegistrationConstraintsRemainOptional() throws {
        let registrations = [
            capabilityRegistration(methods: nil, vpAlgorithms: nil, vcAlgorithms: nil),
            capabilityRegistration(methods: ["did:jwk"], vpAlgorithms: nil, vcAlgorithms: nil),
            capabilityRegistration(methods: nil, vpAlgorithms: ["ES256"], vcAlgorithms: nil)
        ]
        for registration in registrations {
            let request = try XCTUnwrap(PresentationRequestToken(
                headers: Header(keyId: "did:test#keyId"),
                content: createMockPresentationRequestClaims(registration: registration)))
            try PresentationRequestValidator(verifier: verifier).validate(request: request, usingKeys: [mockDidPublicKey])
        }
        XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
    }

    func testLegacyOptionalListsDoNotIntroduceHolderInventoryRequirements() throws {
        let registrations = [
            capabilityRegistration(methods: nil, vpAlgorithms: nil, vcAlgorithms: nil),
            capabilityRegistration(methods: ["did:ion"], vpAlgorithms: nil, vcAlgorithms: nil),
            capabilityRegistration(methods: nil, vpAlgorithms: ["ES256K"], vcAlgorithms: nil),
            capabilityRegistration(methods: nil, vpAlgorithms: nil, vcAlgorithms: ["ES256K"])
        ]
        for capabilities in [[], [PresentationResponseCapability(method: "did:jwk", algorithm: "ES256")]] {
            for registration in registrations {
                let request = try XCTUnwrap(PresentationRequestToken(
                    headers: Header(keyId: "did:test#keyId"),
                    content: createMockPresentationRequestClaims(registration: registration)))
                try PresentationRequestValidator(verifier: verifier, responseCapabilities: capabilities)
                    .validate(request: request, usingKeys: [mockDidPublicKey])
            }
        }
        XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
    }

    func testFipsRegistrationStillRequiresIdentityAndSignatureValidation() throws {
        let registration = capabilityRegistration(methods: ["did:jwk"], vpAlgorithms: ["ES256"], vcAlgorithms: ["ES256"])
        let request = try XCTUnwrap(PresentationRequestToken(
            headers: Header(keyId: "did:test#keyId"),
            content: createMockPresentationRequestClaims(registration: registration)))
        XCTAssertThrowsError(try PresentationRequestValidator(verifier: MockTokenVerifier(isTokenValid: false))
            .validate(request: request, usingKeys: [mockDidPublicKey])) { error in
            XCTAssertEqual(error as? PresentationRequestValidatorError, .invalidSignature)
        }
        let inconsistentRequest = try XCTUnwrap(PresentationRequestToken(
            headers: Header(keyId: "did:test#keyId"),
            content: createMockPresentationRequestClaims(clientID: "did:test:other", registration: registration)))
        XCTAssertThrowsError(try PresentationRequestValidator(verifier: verifier)
            .validate(request: inconsistentRequest, usingKeys: [mockDidPublicKey])) { error in
            XCTAssertEqual(error as? PresentationRequestValidatorError, .clientIdentifierDoesNotMatchSigner)
        }
    }

    private func capabilityRegistration(methods: [String]?, vpAlgorithms: [String]?,
                                        vcAlgorithms: [String]?) -> RegistrationClaims {
        return RegistrationClaims(clientName: nil, clientPurpose: nil, logoURI: nil,
                                  subjectIdentifierTypesSupported: methods,
                                  vpFormats: SupportedVerifiablePresentationFormats(
                                    jwtVP: vpAlgorithms.map { AllowedAlgorithms(algorithms: $0) },
                                    jwtVC: vcAlgorithms.map { AllowedAlgorithms(algorithms: $0) }),
                                  scenario: nil)
    }
    
    func testRejectsClientIdNotBoundToSigner() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        for clientID in [nil, "", "did:test:other", "did:test#keyId", "did:test:long-form"] as [String?] {
            let request = try createSerializedRequest(clientID: clientID)
            XCTAssertThrowsError(try validator.validate(request: request, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, .clientIdentifierDoesNotMatchSigner)
            }
        }
        XCTAssertFalse(MockTokenVerifier.wasVerifyCalled)
    }

    func testRejectsIssuerNotBoundToSigner() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        for issuer in ["", "did:test:other", "did:test#keyId"] {
            let request = try createSerializedRequest(issuer: issuer)
            XCTAssertThrowsError(try validator.validate(request: request, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, .issuerDoesNotMatchSigner)
            }
        }
        XCTAssertFalse(MockTokenVerifier.wasVerifyCalled)
    }

    func testAcceptsMatchingIdentityWithOptionalIssuer() throws {
        let validator = PresentationRequestValidator(verifier: verifier)
        for issuer in [nil, "did:test"] as [String?] {
            let request = try createSerializedRequest(issuer: issuer)
            let claims: OIDCClaims = request.content
            XCTAssertEqual(claims.issuer, issuer)
            try validator.validate(request: request, usingKeys: [mockDidPublicKey])
        }
        let nullIssuerRequest = try createSerializedRequestWithExplicitNullIssuer()
        XCTAssertNil(nullIssuerRequest.content.issuer)
        try validator.validate(request: nullIssuerRequest, usingKeys: [mockDidPublicKey])
        XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
    }

    func testMatchingIdentityStillRequiresValidSignature() throws {
        for validateIdentity in [true, false] {
            let validator = PresentationRequestValidator(verifier: MockTokenVerifier(isTokenValid: false),
                                                         validateIdentity: validateIdentity)
            let request = try createSerializedRequest(issuer: "did:test")
            XCTAssertThrowsError(try validator.validate(request: request, usingKeys: [mockDidPublicKey])) { error in
                XCTAssertEqual(error as? PresentationRequestValidatorError, .invalidSignature)
            }
        }
        XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
    }

    func testIdentityRollbackAcceptsLegacyIdentities() throws {
        let validator = PresentationRequestValidator(verifier: verifier, validateIdentity: false)
        for clientID in [nil, "", "did:test:other", "did:test#keyId"] as [String?] {
            let request = try createSerializedRequest(clientID: clientID, issuer: "did:test:other")
            try validator.validate(request: request, usingKeys: [mockDidPublicKey])
        }
        XCTAssertTrue(MockTokenVerifier.wasVerifyCalled)
    }

    func testIdentityRollbackStillValidatesClaimsAndKeyIdentifier() throws {
        let validator = PresentationRequestValidator(verifier: verifier, validateIdentity: false)
        let expiredClaims = createMockPresentationRequestClaims(timeConstraints: TokenTimeConstraints(expiryInSeconds: -500))
        let expiredRequest = try XCTUnwrap(PresentationRequestToken(headers: Header(keyId: "did:test#keyId"),
                                                                    content: expiredClaims))
        XCTAssertThrowsError(try validator.validate(request: expiredRequest, usingKeys: [mockDidPublicKey])) { error in
            XCTAssertEqual(error as? PresentationRequestValidatorError, .tokenExpired)
        }
        let malformedRequest = try XCTUnwrap(PresentationRequestToken(headers: Header(keyId: "did:test#keyId#other"),
                                                                      content: createMockPresentationRequestClaims()))
        XCTAssertThrowsError(try validator.validate(request: malformedRequest, usingKeys: [mockDidPublicKey])) { error in
            XCTAssertEqual(error as? PresentationRequestValidatorError, .keyIdInTokenHeaderMalformed)
        }
        XCTAssertFalse(MockTokenVerifier.wasVerifyCalled)
    }

    private func createSerializedRequest(clientID: String? = "did:test",
                                         issuer: String? = nil) throws -> PresentationRequestToken {
        let claims = createMockPresentationRequestClaims(clientID: clientID)
        var payload = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(claims)) as? [String: Any])
        payload["iss"] = issuer
        let decodedClaims = try JSONDecoder().decode(PresentationRequestClaims.self,
                                                     from: JSONSerialization.data(withJSONObject: payload))
        let token = try XCTUnwrap(PresentationRequestToken(headers: Header(keyId: "did:test#keyId"),
                                                          content: decodedClaims))
        return try XCTUnwrap(PresentationRequestToken(from: Data(try token.serialize().utf8)))
    }

    private func createSerializedRequestWithExplicitNullIssuer() throws -> PresentationRequestToken {
        let claims = createMockPresentationRequestClaims()
        var payload = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(claims)) as? [String: Any])
        payload["iss"] = NSNull()
        let header = try JSONEncoder().encode(Header(keyId: "did:test#keyId")).base64URLEncodedString()
        let content = try JSONSerialization.data(withJSONObject: payload).base64URLEncodedString()
        return try XCTUnwrap(PresentationRequestToken(from: Data("\(header).\(content).signature".utf8)))
    }

    private func createMockPresentationRequestClaims(clientID: String? = "did:test",
                                                     responseType: String = VCEntitiesConstants.RESPONSE_TYPE,
                                                     responseMode: String = VCEntitiesConstants.RESPONSE_MODE,
                                                     registration: RegistrationClaims = PresentationRequestValidatorTests.createRegistration(),
                                                     scope: String = VCEntitiesConstants.SCOPE,
                                                     timeConstraints: TokenTimeConstraints = TokenTimeConstraints(expiryInSeconds: 300)) -> PresentationRequestClaims {
        return PresentationRequestClaims(jti: "testId",
                                         clientID: clientID,
                                         redirectURI: "redirectURI",
                                         responseMode: responseMode,
                                         responseType: responseType,
                                         claims: nil,
                                         state: "state",
                                         nonce: "nonce",
                                         scope: scope,
                                         prompt: "create",
                                         registration: registration,
                                         idTokenHint: nil,
                                         iat: timeConstraints.issuedAt,
                                         exp: timeConstraints.expiration,
                                         pin: PinDescriptor(type: "numeric",
                                                            length: 5,
                                                            hash: "",
                                                            salt: nil,
                                                            iterations: nil,
                                                            alg: nil))
    }
    
    private static func createRegistration(expectedSubjectIdentifierType: String = "did:ion",
                                           expectedSupportedAlgorithmForVC: String = "ES256K",
                                           expectedSupportedAlgorithmForVP: String = "ES256K") -> RegistrationClaims {
        let supportedAlgorithmsForVP = AllowedAlgorithms(algorithms: [expectedSupportedAlgorithmForVP])
        let supportedAlgorithmsForVC = AllowedAlgorithms(algorithms: [expectedSupportedAlgorithmForVC])

        
        return RegistrationClaims(clientName: "clientName",
                                  clientPurpose: "clientPurpose",
                                  logoURI: "logoURI",
                                  subjectIdentifierTypesSupported: [expectedSubjectIdentifierType],
                                  vpFormats: SupportedVerifiablePresentationFormats(jwtVP: supportedAlgorithmsForVP, jwtVC: supportedAlgorithmsForVC), scenario: nil)
    }
    
}
