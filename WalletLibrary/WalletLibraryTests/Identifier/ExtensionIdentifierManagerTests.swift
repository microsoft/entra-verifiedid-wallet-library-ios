/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class ExtensionIdentifierManagerTests: XCTestCase
{
    func testCreatedSelfSignedVerifiedId_WhenUnableToFetchIdentifier_ThrowError() async throws
    {
        // Arrange
        let config = LibraryConfiguration()
        let manager = InternalExtensionIdentifierManager(libraryConfiguration: config)
        let mockClaims: [String: String] = [:]
        let mockTypes: [String] = []
        
        // Act
        XCTAssertThrowsError(try manager.createEphemeralSelfSignedVerifiedId(claims: mockClaims,
                                                                             types: mockTypes)) { error in
            XCTAssert(error is IdentifierError)
            
            guard let identifierError = error as? IdentifierError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "verified_id_creation_error")
            XCTAssertEqual(identifierError.message, "Unable to create self signed Verified ID.")
            XCTAssertEqual((identifierError.error as? VerifiedIdError)?.code, "no_holder_identifier_found.")
            XCTAssertEqual((identifierError.error as? VerifiedIdError)?.message, "No Holder Identifiers found.")
        }
    }
    
    func testCreatedSelfSignedVerifiedId_WhenIdentifierThrows_ThrowError() async throws
    {
        // Arrange
        let expectedError = VerifiedIdError(message: "expectedError", code: "expected_error")
        let mockIdentifier = MockHolderIdentifier(expectedErrorToBeThrown: expectedError)
        let config = LibraryConfiguration(identifiers: [mockIdentifier])
        let manager = InternalExtensionIdentifierManager(libraryConfiguration: config)
        let mockClaims: [String: String] = [:]
        let mockTypes: [String] = []
        
        // Act
        XCTAssertThrowsError(try manager.createEphemeralSelfSignedVerifiedId(claims: mockClaims,
                                                                             types: mockTypes)) { error in
            
            
            XCTAssert(error is IdentifierError)
            
            guard let identifierError = error as? IdentifierError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "verified_id_creation_error")
            XCTAssertEqual(identifierError.message, "Unable to create self signed Verified ID.")
            XCTAssertEqual((identifierError.error as? VerifiedIdError)?.code, "expected_error")
            XCTAssertEqual((identifierError.error as? VerifiedIdError)?.message, "expectedError")
        }
    }
    
    func testCreatedSelfSignedVerifiedId_WhenValidInput_ReturnsVerifiedId() async throws
    {
        // Arrange
        let mockIdentifier = MockHolderIdentifier(id: "mockId")
        let config = LibraryConfiguration(identifiers: [mockIdentifier])
        let extensionIdentifierManager = InternalExtensionIdentifierManager(libraryConfiguration: config)
        let mockClaims: [String: String] = [:]
        let mockTypes: [String] = []
        
        // Act
        let verifiedId = try extensionIdentifierManager.createEphemeralSelfSignedVerifiedId(claims: mockClaims,
                                                                                            types: mockTypes)
        
        // Assert
        XCTAssert(verifiedId is SelfSignedVerifiableCredential)
        // TODO: add test to see if claims are added after getClaims() PR is in.
    }
}
