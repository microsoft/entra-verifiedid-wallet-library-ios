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
    
    func testSerialize_WithInvalidRequirement_Returns() throws
    {
        // Arrange
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
            XCTAssertEqual(tracelevel, .VERBOSE)
            XCTAssertEqual(message, "Verified ID serialized to incorrect type.")
        }
        
        let logger = WalletLibraryLogger(consumers: [MockLogConsumer(logCallback: callback)])
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
        let configuration = LibraryConfiguration()
        
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
        let configuration = LibraryConfiguration()
        
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
        let configuration = LibraryConfiguration()
        
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
        let mockIdentifierManager = MockIdentifierManager(doesThrow: true)
        let configuration = LibraryConfiguration(identifierManager: mockIdentifierManager)
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            libraryConfiguration: configuration)
        
        // Act / Assert
        XCTAssertThrowsError(try serializer.build()) { error in
            XCTAssert(error is MockIdentifierManager.ExpectedError)
            XCTAssertEqual((error as? MockIdentifierManager.ExpectedError), .ExpectedToThrow)
        }
    }
    
    func testBuild_WithMissingKeyInIdentifierDocument_ThrowsError() throws
    {
        // Arrange
        let mockIdentifierManager = MockIdentifierManager(mockKeyId: nil)
        let configuration = LibraryConfiguration(identifierManager: mockIdentifierManager)
        
        let serializer = try PresentationExchangeSerializer(request: mockOpenIdRawRequest,
                                                            libraryConfiguration: configuration)
        
        // Act / Assert
        XCTAssertThrowsError(try serializer.build()) { error in
            XCTAssert(error is IdentifierError)
            XCTAssertEqual((error as? IdentifierError)?.code, "no_keys_found_in_document")
            XCTAssertEqual((error as? IdentifierError)?.message, "No keys found in Identifier document.")
        }
    }
    
    func testBuild_WithIdTokenBuilderThrows_ThrowsError() throws
    {
        // Arrange
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
