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

    }
    
    func testSerialize_WithInvalidRequirement_Returns() throws
    {

    }
    
    func testSerialize_WithRequirementSerializeThrows_ThrowsError() throws
    {

    }
    
    func testBuild_WithUnableToFetchIdentifier_ThrowsError() throws
    {

    }
    
    func testBuild_WithMissingKeyInIdentifierDocument_ThrowsError() throws
    {

    }
    
    func testBuild_WithIdTokenBuilderThrows_ThrowsError() throws
    {

    }
    
    func testBuild_WithVPBuilderThrows_ThrowsError() throws
    {

    }
    
    func testBuild_WithOneVP_ReturnsPresentationResponse() throws
    {

    }
    
    func testBuild_WithThreeVP_ReturnsPresentationResponse() throws
    {

    }
    
    private func assertPropertyNotFound(error: Error, property: String)
    {
        XCTAssert(error is RequestProcessorError)
        XCTAssertEqual((error as? RequestProcessorError)?.code, "missing_required_property")
        XCTAssertEqual((error as? RequestProcessorError)?.message, "Unable to create serializer.")
        if let innerError = (error as? RequestProcessorError)?.error
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
    func createPEIdTokenBuilder() -> PresentationExchangeIdTokenBuilding
    {
        return MockPEIdTokenBuilder()
    }
    
    func createVPTokenBuilder(index: Int) ->VerifiablePresentationBuilding
    {
        return MockVPBuilder()
    }
    
    
}

struct MockPEIdTokenBuilder: PresentationExchangeIdTokenBuilding
{
    func build(inputDescriptors: [InputDescriptorMapping],
               definitionId: String,
               audience: String,
               nonce: String,
               identifier: String,
               signingKey: KeyContainer) throws -> PresentationResponseToken
    {
        throw VerifiedIdError(message: "", code: "")
    }
}

struct MockVPBuilder: VerifiablePresentationBuilding
{
    func canInclude(partialInputDescriptor: PartialInputDescriptor) -> Bool
    {
        return true
    }
    
    func add(partialInputDescriptor: PartialInputDescriptor) 
    {
        
    }
    
    func buildInputDescriptors() -> [InputDescriptorMapping] 
    {
        return []
    }
    
    func buildVerifiablePresentation(audience: String, 
                                     nonce: String,
                                     identifier: String,
                                     signingKey: KeyContainer) throws -> VerifiablePresentation
    {
        throw VerifiedIdError(message: "", code: "")
    }
}
