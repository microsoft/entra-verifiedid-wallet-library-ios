/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationExchangeSerializerTests: XCTestCase
{
    func testInit_WithMissingState_ThrowsError() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: nil,
                                                        issuer: "mock issuer",
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
                                                        issuer: nil,
                                                        definitionId: "mock definition id")
        let configuration = LibraryConfiguration()
        
        // Act / Assert
        XCTAssertThrowsError(try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                                libraryConfiguration: configuration)) { error in
            assertPropertyNotFound(error: error, property: "issuer")
        }
    }
    
    func testInit_WithMissingNonce_ThrowsError() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: nil,
                                                        state: "mock state",
                                                        issuer: "mock issuer",
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
                                                        issuer: "mock issuer",
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
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        let configuration = LibraryConfiguration()
        
        // Act / Assert
        XCTAssertNoThrow(try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            libraryConfiguration: configuration))
    }
    
    func testSerialize_WithInvalidRequirement_Returns() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>()
        
        let callback: ((TraceLevel, String, String, String, Int) -> ()) = { (tracelevel, message, _, _, _) in
            // Assert
            XCTAssertEqual(tracelevel, .VERBOSE)
            XCTAssertEqual(message, "Unable to serialize requirement type: WalletLibraryTests.MockRequirement")
        }
        
        let logger = WalletLibraryLogger(consumers: [MockLogConsumer(logCallback: callback)])
        let configuration = LibraryConfiguration(logger: logger)
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockRequirement(id: "mock id")
        
        // Act
        try serializer.serialize(requirement: mockRequirement, 
                                 verifiedIdSerializer: mockVerifiedIdSerializer)
    }
    
    func testSerialize_WithRequirementSerializeThrows_ThrowsError() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        
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
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<Int>(expectedResult: 3)
        
        let callback: ((TraceLevel, String, String, String, Int) -> ()) = { (tracelevel, message, _, _, _) in
            // Assert
            XCTAssertEqual(tracelevel, .VERBOSE)
            XCTAssertEqual(message, "Verified ID serialized to incorrect type.")
        }
        
        let logger = WalletLibraryLogger(consumers: [MockLogConsumer(logCallback: callback)])
        let configuration = LibraryConfiguration(logger: logger)
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockPresentationExchangeRequirement(inputDescriptorId: "mock id")
        
        // Act
        XCTAssertNoThrow(try serializer.serialize(requirement: mockRequirement,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
    }
    
    func testSerialize_WithValidRequirement_AddsBuilderToList() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>(expectedResult: "serializedVC")
        
        var didCreateVPBuilder = false
        
        let vpTokenBuilderSpy: (Int) -> () = { actualIndex in
            didCreateVPBuilder = true
            XCTAssertEqual(0, actualIndex)
        }
        
        let mockTokenBuilderFactory = MockTokenBuilderFactory(vpTokenBuilderSpy: vpTokenBuilderSpy)
        let configuration = LibraryConfiguration()
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            tokenBuilderFactory: mockTokenBuilderFactory,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockPresentationExchangeRequirement(inputDescriptorId: "mock id")
        
        // Act
        XCTAssertNoThrow(try serializer.serialize(requirement: mockRequirement,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        XCTAssert(didCreateVPBuilder)
    }
    
    func testSerialize_WithTwoNonCompatReqs_AddsTwoBuildersToList() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>(expectedResult: "serializedVC")
        
        var vpBuilderCreationCount = 0
        
        let vpTokenBuilderSpy: (Int) -> () = { actualIndex in
            XCTAssertEqual(vpBuilderCreationCount, actualIndex)
            vpBuilderCreationCount = vpBuilderCreationCount + 1
        }
        
        let mockTokenBuilderFactory = MockTokenBuilderFactory(vpTokenBuilderSpy: vpTokenBuilderSpy)
        let configuration = LibraryConfiguration()
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            tokenBuilderFactory: mockTokenBuilderFactory,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockPresentationExchangeRequirement(inputDescriptorId: "1")
        let nonCompatReq = MockPresentationExchangeRequirement(inputDescriptorId: "2", exclusivePresentationWith: ["1"])
        
        // Act
        XCTAssertNoThrow(try serializer.serialize(requirement: mockRequirement,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        XCTAssertNoThrow(try serializer.serialize(requirement: nonCompatReq,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        XCTAssertEqual(vpBuilderCreationCount, 2)
    }
    
    func testSerialize_WithTwoCompatReqs_AddsPartialToList() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>(expectedResult: "serializedVC")
        
        var vpBuilderCreationCount = 0
        
        let vpTokenBuilderSpy: (Int) -> () = { actualIndex in
            XCTAssertEqual(vpBuilderCreationCount, actualIndex)
            vpBuilderCreationCount = vpBuilderCreationCount + 1
        }
        
        let mockTokenBuilderFactory = MockTokenBuilderFactory(vpTokenBuilderSpy: vpTokenBuilderSpy)
        let configuration = LibraryConfiguration()
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            tokenBuilderFactory: mockTokenBuilderFactory,
                                                            libraryConfiguration: configuration)
        
        let mockRequirement = MockPresentationExchangeRequirement(inputDescriptorId: "1")
        let nonCompatReq = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        
        // Act
        XCTAssertNoThrow(try serializer.serialize(requirement: mockRequirement,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        XCTAssertNoThrow(try serializer.serialize(requirement: nonCompatReq,
                                                  verifiedIdSerializer: mockVerifiedIdSerializer))
        XCTAssertEqual(vpBuilderCreationCount, 1)
    }
    
    func testBuild_WithUnableToFetchIdentifier_ThrowsError() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        
        let mockIdentifierManager = MockIdentifierManager(doesThrow: true)
        let configuration = LibraryConfiguration(identifierManager: mockIdentifierManager)
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            libraryConfiguration: configuration)
        
        // Act
        XCTAssertThrowsError(try serializer.build()) { error in
            XCTAssert(error is MockIdentifierManager.ExpectedError)
            XCTAssertEqual((error as? MockIdentifierManager.ExpectedError), .ExpectedToThrow)
        }
    }
    
    func testBuild_WithMissingKeyInIdentifierDocument_ThrowsError() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        
        let mockIdentifierManager = MockIdentifierManager(mockKeyId: nil)
        let configuration = LibraryConfiguration(identifierManager: mockIdentifierManager)
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            libraryConfiguration: configuration)
        
        // Act
        XCTAssertThrowsError(try serializer.build()) { error in
            XCTAssert(error is IdentifierError)
            XCTAssertEqual((error as? IdentifierError)?.code, "no_keys_found_in_document")
            XCTAssertEqual((error as? IdentifierError)?.message, "No keys found in Identifier document.")
        }
    }
    
    func testBuild_WithIdTokenBuilderThrows_ThrowsError() throws
    {
        // Arrange
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        
        let mockTokenBuilderFactory = MockTokenBuilderFactory(doesPEIdTokenBuilderThrow: true)
        let configuration = LibraryConfiguration()
        
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
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>(expectedResult: "serializedVC")
        
        let mockTokenBuilderFactory = MockTokenBuilderFactory(doesVPTokenBuilderThrow: true)
        let configuration = LibraryConfiguration()
        
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
        let mockOpenIdRawRequest = MockOpenIdRawRequest(nonce: "mock nonce",
                                                        state: "mock state",
                                                        issuer: "mock issuer",
                                                        definitionId: "mock definition id")
        
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>(expectedResult: "serializedVC")
        
        let mockTokenBuilderFactory = MockTokenBuilderFactory()
        let configuration = LibraryConfiguration()
        
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

struct MockTokenBuilderFactory: TokenBuilderFactory
{
    private let vpTokenBuilderSpy: ((Int) -> ())?
    
    private let doesPEIdTokenBuilderThrow: Bool
    
    private let doesVPTokenBuilderThrow: Bool
    
    let expectedResultForPEIdToken: PresentationResponseToken
    
    let expectedResultForVPToken: VerifiablePresentation
    
    init(vpTokenBuilderSpy: ((Int) -> ())? = nil,
         doesPEIdTokenBuilderThrow: Bool = false,
         doesVPTokenBuilderThrow: Bool = false)
    {
        self.vpTokenBuilderSpy = vpTokenBuilderSpy
        self.doesPEIdTokenBuilderThrow = doesPEIdTokenBuilderThrow
        self.doesVPTokenBuilderThrow = doesVPTokenBuilderThrow
        self.expectedResultForPEIdToken = PresentationResponseToken(headers: Header(),
                                                                    content: PresentationResponseClaims())!
        self.expectedResultForVPToken = VerifiablePresentation(headers: Header(),
                                                               content: VerifiablePresentationClaims(verifiablePresentation: nil))!
    }
    
    func createPEIdTokenBuilder() -> PresentationExchangeIdTokenBuilding
    {
        return MockPEIdTokenBuilder(doesThrow: doesPEIdTokenBuilderThrow, 
                                    expectedResult: expectedResultForPEIdToken)
    }
    
    func createVPTokenBuilder(index: Int) ->VerifiablePresentationBuilding
    {
        vpTokenBuilderSpy?(index)
        return MockVPBuilder(index: index,
                             doesThrow: doesVPTokenBuilderThrow,
                             expectedResult: expectedResultForVPToken)
    }
    
    
}

struct MockPEIdTokenBuilder: PresentationExchangeIdTokenBuilding
{
    enum ExpectedError: Error
    {
        case ExpectedToThrow
        case ExpectedResultNotSet
    }
    
    private let doesThrow: Bool
    
    private let expectedResult: PresentationResponseToken
    
    init(doesThrow: Bool = false, 
         expectedResult: PresentationResponseToken)
    {
        self.doesThrow = doesThrow
        self.expectedResult = expectedResult
    }
    
    func build(inputDescriptors: [InputDescriptorMapping],
               definitionId: String,
               audience: String,
               nonce: String,
               identifier: String,
               signingKey: KeyContainer) throws -> PresentationResponseToken
    {
        if doesThrow
        {
            throw ExpectedError.ExpectedToThrow
        }
        
        return expectedResult
    }
}

struct MockVPBuilder: VerifiablePresentationBuilding
{
    enum ExpectedError: Error
    {
        case ExpectedToThrow
    }
    
    private let doesThrow: Bool
    
    private let expectedResult: VerifiablePresentation
    
    private let wrappedBuilder: VerifiablePresentationBuilder
    
    init(index: Int,
         doesThrow: Bool = false,
         expectedResult: VerifiablePresentation)
    {
        self.wrappedBuilder = VerifiablePresentationBuilder(index: index)
        self.doesThrow = doesThrow
        self.expectedResult = expectedResult
    }
    
    func canInclude(partialInputDescriptor: PartialInputDescriptor) -> Bool
    {
        wrappedBuilder.canInclude(partialInputDescriptor: partialInputDescriptor)
    }
    
    func add(partialInputDescriptor: PartialInputDescriptor) 
    { 
        wrappedBuilder.add(partialInputDescriptor: partialInputDescriptor)
    }
    
    func buildInputDescriptors() -> [InputDescriptorMapping] 
    {
        wrappedBuilder.buildInputDescriptors()
    }
    
    func buildVerifiablePresentation(audience: String, 
                                     nonce: String,
                                     identifier: String,
                                     signingKey: KeyContainer) throws -> VerifiablePresentation
    {
        if doesThrow
        {
            throw ExpectedError.ExpectedToThrow
        }
        
        return expectedResult
    }
}

struct MockVerifiedIdSerializer<SerializedFormat>: VerifiedIdSerializing
{
    enum ExpectedError: Error
    {
        case SerializerShouldThrow
        case ExpectedResultNotSet
    }
    
    typealias SerializedFormat = SerializedFormat
    
    private let doesThrow: Bool
    
    private let expectedResult: SerializedFormat?
    
    init(doesThrow: Bool = false,
         expectedResult: SerializedFormat? = nil)
    {
        self.doesThrow = doesThrow
        self.expectedResult = expectedResult
    }
    
    func serialize(verifiedId: WalletLibrary.VerifiedId) throws -> SerializedFormat 
    {
        if doesThrow
        {
            throw ExpectedError.SerializerShouldThrow
        }
        
        if let expectedResult = expectedResult
        {
            return expectedResult
        }
        
        throw ExpectedError.ExpectedResultNotSet
    }
}
