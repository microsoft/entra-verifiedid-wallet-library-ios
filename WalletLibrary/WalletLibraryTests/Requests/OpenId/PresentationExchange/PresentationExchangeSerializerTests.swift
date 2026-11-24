/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationExchangeSerializerTests: XCTestCase
{
    private let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                            state: "mock state",
                                                            clientId: "mock client id",
                                                            definitionId: "mock definition id")
    
    func testInit_WithMissingState_ThrowsError() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: nil,
                                                        clientId: "mock client id",
                                                        definitionId: "mock definition id")
        let configuration = LibraryConfiguration()
        
        // Act / Assert
        XCTAssertThrowsError(try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                                libraryConfiguration: configuration)) { error in
            assertPropertyNotFound(error: error, property: "state")
        }
    }
    
    func testInit_WithMissingAudience_ThrowsError() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        clientId: nil,
                                                        definitionId: "mock definition id")
        let configuration = LibraryConfiguration()
        
        // Act / Assert
        XCTAssertThrowsError(try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                                libraryConfiguration: configuration)) { error in
            assertPropertyNotFound(error: error, property: "client_id")
        }
    }
    
    func testInit_WithMissingNonce_ThrowsError() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: nil,
                                                        state: "mock state",
                                                        clientId: "mock client id",
                                                        definitionId: "mock definition id")
        let configuration = LibraryConfiguration()
        
        // Act / Assert
        XCTAssertThrowsError(try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                                libraryConfiguration: configuration)) { error in
            assertPropertyNotFound(error: error, property: "nonce")
        }
    }
    
    func testInit_WithMissingDefinitionId_ThrowsError() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        clientId: "mock client id",
                                                        definitionId: nil)
        let configuration = LibraryConfiguration()
        
        // Act / Assert
        XCTAssertThrowsError(try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                                libraryConfiguration: configuration)) { error in
            assertPropertyNotFound(error: error, property: "definitionId")
        }
    }
    
    func testInit_WithValidParams_ReturnsSerializer() throws
    {
        // Arrange
        let configuration = LibraryConfiguration()
        
        // Act / Assert
        XCTAssertNoThrow(try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            libraryConfiguration: configuration))
    }
    
    func testSerialize_WithRequirementSerializeThrows_ThrowsError() throws
    {
        // Arrange
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>(doesThrow: true)
        
        let configuration = LibraryConfiguration()
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockPresentationExchangeRequirement(inputDescriptorId: "mock id")
        
        // Act / Assert
        XCTAssertThrowsError(try serializer.serialize(requirement: mockRequirement,
                                                      verifiedIdSerializer: mockVerifiedIdSerializer)) { error in
            XCTAssert(error is MockVerifiedIdSerializer<String>.ExpectedError)
            XCTAssertEqual((error as? MockVerifiedIdSerializer<String>.ExpectedError), .SerializerShouldThrow)
        }
    }
    
    func testSerialize_WithRequirementReturnsInvalidType_Returns() throws
    {
        // Arrange
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<Int>(expectedResult: 3)
        
        let callback: ((TraceLevel, String, String, String, Int) -> ()) = { (tracelevel, message, _, _, _) in
            // Assert
            XCTAssertEqual(tracelevel, .WARN)
            XCTAssertEqual(message,
                           "Unable to add requirement to VP grouping: MockPresentationExchangeRequirement")
        }
        
        let logger = WalletLibraryLogger()
        logger.add(consumer: MockLogConsumer(logCallback: callback))
        let configuration = LibraryConfiguration(logger: logger)
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockPresentationExchangeRequirement(inputDescriptorId: "mock id")
        
        // Act / Assert
        XCTAssertNoThrow(try serializer.serialize(requirement: mockRequirement,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
    }
    
    func testSerialize_WithValidRequirement_AddsBuilderToList() throws
    {
        // Arrange
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>(expectedResult: "serializedVC")
        
        var didCreateVPBuilder = false
        
        let vpTokenBuilderSpy: (Int) -> () = { actualIndex in
            didCreateVPBuilder = true
            XCTAssertEqual(0, actualIndex)
        }
        
        let mockTokenBuilderFactory = MockTokenBuilderFactory(vpTokenBuilderSpy: vpTokenBuilderSpy)
        let mockIdentifier = MockHolderIdentifier()
        let configuration = LibraryConfiguration(
            identifiers: [mockIdentifier]
        )
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            tokenBuilderFactory: mockTokenBuilderFactory,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockPresentationExchangeRequirement(inputDescriptorId: "mock id")
        
        // Act / Assert
        XCTAssertNoThrow(try serializer.serialize(requirement: mockRequirement,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        XCTAssert(didCreateVPBuilder)
    }
    
    func testSerialize_WithTwoNonCompatReqs_AddsTwoBuildersToList() throws
    {
        // Arrange
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>(expectedResult: "serializedVC")
        
        var vpBuilderCreationCount = 0
        
        let vpTokenBuilderSpy: (Int) -> () = { actualIndex in
            XCTAssertEqual(vpBuilderCreationCount, actualIndex)
            vpBuilderCreationCount = vpBuilderCreationCount + 1
        }
        
        let mockTokenBuilderFactory = MockTokenBuilderFactory(vpTokenBuilderSpy: vpTokenBuilderSpy)
        let mockIdentifier = MockHolderIdentifier()
        let configuration = LibraryConfiguration(
            identifiers: [mockIdentifier]
        )
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            tokenBuilderFactory: mockTokenBuilderFactory,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockPresentationExchangeRequirement(inputDescriptorId: "1")
        let nonCompatReq = MockPresentationExchangeRequirement(inputDescriptorId: "2", exclusivePresentationWith: ["1"])
        
        // Act / Assert
        XCTAssertNoThrow(try serializer.serialize(requirement: mockRequirement,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        XCTAssertNoThrow(try serializer.serialize(requirement: nonCompatReq,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        XCTAssertEqual(vpBuilderCreationCount, 2)
    }
    
    func testSerialize_WithTwoCompatReqs_AddsPartialToList() throws
    {
        // Arrange
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>(expectedResult: "serializedVC")
        
        var vpBuilderCreationCount = 0
        
        let vpTokenBuilderSpy: (Int) -> () = { actualIndex in
            XCTAssertEqual(vpBuilderCreationCount, actualIndex)
            vpBuilderCreationCount = vpBuilderCreationCount + 1
        }
        
        let mockTokenBuilderFactory = MockTokenBuilderFactory(vpTokenBuilderSpy: vpTokenBuilderSpy)
        let mockIdentifier = MockHolderIdentifier()
        let configuration = LibraryConfiguration(
            identifiers: [mockIdentifier]
        )
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            tokenBuilderFactory: mockTokenBuilderFactory,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockPresentationExchangeRequirement(inputDescriptorId: "1")
        let nonCompatReq = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        
        // Act / Assert
        XCTAssertNoThrow(try serializer.serialize(requirement: mockRequirement,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        XCTAssertNoThrow(try serializer.serialize(requirement: nonCompatReq,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        XCTAssertEqual(vpBuilderCreationCount, 1)
    }
    
    func testBuild_WithUnableToFetchIdentifier_ThrowsError() throws
    {
        // Arrange
        let configuration = LibraryConfiguration()
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            libraryConfiguration: configuration)
        
        // Act / Assert
        XCTAssertThrowsError(try serializer.build()) { error in
            XCTAssertEqual((error as? VerifiedIdError)?.code, "no_holder_identifier_found.")
            XCTAssertEqual((error as? VerifiedIdError)?.message, "No Holder Identifiers found.")
        }
    }

    
    func testBuild_WithIdTokenBuilderThrows_ThrowsError() throws
    {
        // Arrange
        let mockTokenBuilderFactory = MockTokenBuilderFactory(doesPEIdTokenBuilderThrow: true)
        let mockIdentifier = MockHolderIdentifier(id: "mockId")
        let configuration = LibraryConfiguration(identifiers: [mockIdentifier])
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            tokenBuilderFactory: mockTokenBuilderFactory,
                                                            libraryConfiguration: configuration)
        
        // Act / Assert
        XCTAssertThrowsError(try serializer.build()) { error in
            XCTAssert(error is MockPEIdTokenBuilder.ExpectedError)
            XCTAssertEqual((error as? MockPEIdTokenBuilder.ExpectedError), .ExpectedToThrow)
        }
    }
    
    func testBuild_WithVPBuilderThrows_ThrowsError() throws
    {
        // Arrange
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>(expectedResult: "serializedVC")
        
        let mockTokenBuilderFactory = MockTokenBuilderFactory(doesVPTokenBuilderThrow: true)
        let configuration = LibraryConfiguration(identifiers: [MockHolderIdentifier(id: "mockId")])
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            tokenBuilderFactory: mockTokenBuilderFactory,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockPresentationExchangeRequirement(inputDescriptorId: "mock id")
        
        // Act / Assert
        XCTAssertNoThrow(try serializer.serialize(requirement: mockRequirement,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        XCTAssertThrowsError(try serializer.build()) { error in
            XCTAssert(error is MockVPBuilder.ExpectedError)
            XCTAssertEqual((error as? MockVPBuilder.ExpectedError), .ExpectedToThrow)
        }
    }
    
    func testBuild_WithOneVP_ReturnsPresentationResponse() throws
    {
        // Arrange
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>(expectedResult: "serializedVC")
        
        let mockTokenBuilderFactory = MockTokenBuilderFactory()
        let configuration = LibraryConfiguration(identifiers: [MockHolderIdentifier(id: "testDid")])
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            tokenBuilderFactory: mockTokenBuilderFactory,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockPresentationExchangeRequirement(inputDescriptorId: "mock id")
        
        // Act / Assert
        XCTAssertNoThrow(try serializer.serialize(requirement: mockRequirement,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        let result = try serializer.build()
        
        XCTAssertEqual(try result.idToken.serialize(),
                       try mockTokenBuilderFactory.expectedResultForPEIdToken.serialize())
        XCTAssertEqual(try result.vpTokens.first?.serialize(),
                       try mockTokenBuilderFactory.expectedResultForVPToken.serialize())
        XCTAssertEqual(result.state,
                       mockOpenIdRawRequest.state)

    }
    
    func testLegacySelectionIsPreservedAndNewJwkMetadataSelectsCompatibleHolder() throws
    {
        let fips = MockHolderIdentifier(id: "did:jwk:holder", algorithm: "ES256", method: "did:jwk", keyReference: "0")
        let legacy = MockHolderIdentifier(id: "did:ion:holder", algorithm: "ES256K", method: "did:ion", keyReference: "key")
        let cases: [([String], [String], String, [MockHolderIdentifier], MockHolderIdentifier)] = [
            (["did:ion"], ["ES256K"], "ES256K", [legacy], legacy),
            (["did:ion", "did:jwk"], ["ES256K"], "ES256K", [fips, legacy], fips),
            (["did:ion", "did:jwk"], ["ES256K"], "ES256K", [fips], fips),
            (["did:jwk"], ["ES256"], "ES256", [legacy, fips], fips),
            (["did:ion", "did:jwk"], ["ES256K", "ES256"], "ES256K", [fips, legacy], fips),
            (["did:jwk"], ["ES256"], "EdDSA", [fips], fips)
        ]
        for (methods, algorithms, credentialAlgorithm, identifiers, expectedHolder) in cases
        {
            let request = requestWithRegistration(methods: methods, vpAlgorithms: algorithms,
                                                  vcAlgorithms: [credentialAlgorithm])
            let configuration = LibraryConfiguration(identifiers: identifiers)
            let serializer = try PresentationExchangeSerializer(request: request, libraryConfiguration: configuration)
            let credential = try serializedCredential(algorithm: credentialAlgorithm)
            try serializer.serialize(requirement: MockPresentationExchangeRequirement(inputDescriptorId: "id"),
                                     verifiedIdSerializer: MockVerifiedIdSerializer<String>(expectedResult: credential))

            let response = try serializer.build()

            XCTAssertEqual(response.idToken.headers.algorithm, expectedHolder.algorithm)
            XCTAssertEqual(response.idToken.content.subject, expectedHolder.id)
            let vp = try XCTUnwrap(response.vpTokens.first)
            XCTAssertEqual(vp.headers.algorithm, expectedHolder.algorithm)
            XCTAssertEqual(vp.content.issuerOfVp, expectedHolder.id)
            XCTAssertEqual(vp.content.verifiablePresentation.verifiableCredential, [credential])
        }
    }

    func testNewJwkMetadataDoesNotFallBackToLegacyHolder() throws
    {
        let legacy = MockHolderIdentifier(id: "did:ion:holder", algorithm: "ES256K", method: "did:ion")
        let request = requestWithRegistration(methods: ["did:jwk"], vpAlgorithms: ["ES256"], vcAlgorithms: nil)
        let serializer = try PresentationExchangeSerializer(request: request,
                                                            libraryConfiguration: LibraryConfiguration(identifiers: [legacy]))
        XCTAssertThrowsError(try serializer.build()) { error in
            XCTAssertEqual((error as? VerifiedIdError)?.code, "no_holder_identifier_found.")
        }
    }

    func testRegistrationDoesNotIntroduceEmbeddedCredentialAlgorithmRejection() throws
    {
        let legacy = MockHolderIdentifier(id: "did:ion:holder", algorithm: "ES256K", method: "did:ion")
        let fips = MockHolderIdentifier(id: "did:jwk:holder", algorithm: "ES256", method: "did:jwk")
        let requests = [
            requestWithRegistration(methods: ["did:ion", "did:jwk"], vpAlgorithms: ["ES256K"], vcAlgorithms: ["ES256K"]),
            requestWithRegistration(methods: ["did:jwk"], vpAlgorithms: ["ES256"], vcAlgorithms: ["ES256"]),
            requestWithRegistration(methods: nil, vpAlgorithms: nil, vcAlgorithms: nil)
        ]
        for request in requests
        {
            let serializer = try PresentationExchangeSerializer(request: request,
                                                                libraryConfiguration: LibraryConfiguration(identifiers: [fips, legacy]))
            let credential = try serializedCredential(algorithm: "EdDSA")
            try serializer.serialize(requirement: MockPresentationExchangeRequirement(inputDescriptorId: "id"),
                                     verifiedIdSerializer: MockVerifiedIdSerializer<String>(expectedResult: credential))
            let response = try serializer.build()
            XCTAssertEqual(response.vpTokens.first?.content.verifiablePresentation.verifiableCredential, [credential])
        }
    }

    func testRegistrationPreservesCredentialSubjectBinding() throws
    {
        let fips = MockHolderIdentifier(id: "did:jwk:holder", algorithm: "ES256", method: "did:jwk")
        let legacy = MockHolderIdentifier(id: "did:ion:holder", algorithm: "ES256K", method: "did:ion")
        let credential = try serializedCredential(algorithm: "ES256", subject: legacy.id)
        let requirement = PresentationExchangeVerifiedIdRequirement(
            encrypted: false, required: true, types: [], purpose: nil, issuanceOptions: [],
            id: nil, constraint: MockConstraint(doesMatchResult: true), inputDescriptorId: "id",
            format: "jwt_vc", exclusivePresentationWith: nil)
        try requirement.fulfill(with: SelfSignedVerifiableCredential(raw: credential)).get()

        let mixedRequest = requestWithRegistration(methods: ["did:ion", "did:jwk"],
                                                  vpAlgorithms: ["ES256", "ES256K"], vcAlgorithms: ["ES256K"])
        let configuration = LibraryConfiguration(identifiers: [fips, legacy])
        let mixedSerializer = try PresentationExchangeSerializer(request: mixedRequest, libraryConfiguration: configuration)
        try mixedSerializer.serialize(requirement: requirement,
                                      verifiedIdSerializer: MockVerifiedIdSerializer<String>(expectedResult: credential))
        let response = try mixedSerializer.build()
        XCTAssertEqual(response.idToken.content.subject, fips.id)
        XCTAssertEqual(response.vpTokens.first?.content.issuerOfVp, legacy.id)
        XCTAssertEqual(response.vpTokens.first?.headers.algorithm, legacy.algorithm)

        let fipsRequest = requestWithRegistration(methods: ["did:jwk"], vpAlgorithms: ["ES256"], vcAlgorithms: ["ES256"])
        let fipsSerializer = try PresentationExchangeSerializer(request: fipsRequest, libraryConfiguration: configuration)
        XCTAssertThrowsError(try fipsSerializer.serialize(
            requirement: requirement,
            verifiedIdSerializer: MockVerifiedIdSerializer<String>(expectedResult: credential))) { error in
            XCTAssertEqual((error as? TokenValidationError)?.message,
                           "Unable to create a token using identifier: \(legacy.id)")
        }
    }

    private func requestWithRegistration(methods: [String]?, vpAlgorithms: [String]?,
                                         vcAlgorithms: [String]?) -> MockOpenIdRawRequest
    {
        var request = mockOpenIdRawRequest
        request.registration = RegistrationClaims(
            clientName: nil, clientPurpose: nil, logoURI: nil, subjectIdentifierTypesSupported: methods,
            vpFormats: SupportedVerifiablePresentationFormats(
                jwtVP: vpAlgorithms.map { AllowedAlgorithms(algorithms: $0) },
                jwtVC: vcAlgorithms.map { AllowedAlgorithms(algorithms: $0) }),
            scenario: nil)
        return request
    }

    private func serializedCredential(algorithm: String, subject: String? = nil) throws -> String
    {
        let claims = VCClaims(jti: "credential", iss: "did:test:issuer", sub: subject,
                              iat: Int(Date().timeIntervalSince1970), exp: nil, vc: nil)
        let token = try XCTUnwrap(VerifiableCredential(headers: Header(algorithm: algorithm), content: claims))
        return try token.serialize()
    }

    private func assertPropertyNotFound(error: Error, property: String)
    {
        XCTAssert(error is PresentationExchangeError)
        XCTAssertEqual((error as? PresentationExchangeError)?.code, "missing_required_property")
        XCTAssertEqual((error as? PresentationExchangeError)?.message, "Unable to create serializer.")
        if let innerError = (error as? PresentationExchangeError)?.error
        {
            print(innerError)
            XCTAssert(innerError is MappingError)
            XCTAssertEqual((innerError as? MappingError), .PropertyNotPresent(property: property,
                                                                              in: "MockOpenIdRawRequest"))
        }
    }
}
