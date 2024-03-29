/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class ExtensionIdentifierManagerTests: XCTestCase
{
    func testCreatedSelfSignedVerifiedId_WhenIdentifierManagerThrows_ThrowError() async throws
    {
        // Arrange
        let mockIdentifierManager = MockIdentifierManager(doesThrow: true)
        let config = LibraryConfiguration()
        let extensionIdentifierManager = InternalExtensionIdentifierManager(identifierManager: mockIdentifierManager,
                                                                            libraryConfiguration: config)
        let mockClaims: [String: String] = [:]
        let mockTypes: [String] = []
        
        // Act
        XCTAssertThrowsError(try extensionIdentifierManager.createEphemeralSelfSignedVerifiedId(claims: mockClaims,
                                                                                                types: mockTypes)) { error in
            print(error)
            XCTAssert(error is IdentifierError)
            
            guard let identifierError = error as? IdentifierError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "verified_id_creation_error")
            XCTAssertEqual(identifierError.message, "Unable to create self signed Verified ID.")
            XCTAssertEqual(identifierError.error as? MockIdentifierManager.ExpectedError,
                           MockIdentifierManager.ExpectedError.ExpectedToThrow)
        }
    }
    
    func testCreatedSelfSignedVerifiedId_WhenMissingKeysInIdentifierDocument_ThrowError() async throws
    {
        // Arrange
        let mockIdentifierManager = MockIdentifierManager(mockKeyId: nil)
        let config = LibraryConfiguration()
        let extensionIdentifierManager = InternalExtensionIdentifierManager(identifierManager: mockIdentifierManager,
                                                                            libraryConfiguration: config)
        let mockClaims: [String: String] = [:]
        let mockTypes: [String] = []
        
        // Act
        XCTAssertThrowsError(try extensionIdentifierManager.createEphemeralSelfSignedVerifiedId(claims: mockClaims,
                                                                                                types: mockTypes)) { error in
            XCTAssert(error is IdentifierError)
            
            guard let identifierError = error as? IdentifierError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "verified_id_creation_error")
            XCTAssertEqual(identifierError.message, "Unable to create self signed Verified ID.")
            XCTAssert(identifierError.error is IdentifierError)
            
            guard let nestedError = identifierError.error as? IdentifierError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(nestedError.code, "no_keys_found_in_document")
            XCTAssertEqual(nestedError.message, "No keys found in Identifier document.")
        }
    }
    
    func testCreatedSelfSignedVerifiedId_WhenErrorWhileSigning_ThrowError() async throws
    {
        // Arrange
        let mockIdentifierManager = MockIdentifierManager(mockKeyId: "mockKeyId")
        let config = LibraryConfiguration()
        let mockSigner = MockSigner(doesSignThrow: true)
        let extensionIdentifierManager = InternalExtensionIdentifierManager(identifierManager: mockIdentifierManager,
                                                                            libraryConfiguration: config,
                                                                            tokenSigner: mockSigner)
        let mockClaims: [String: String] = [:]
        let mockTypes: [String] = []
        
        // Act
        XCTAssertThrowsError(try extensionIdentifierManager.createEphemeralSelfSignedVerifiedId(claims: mockClaims,
                                                                                                types: mockTypes)) { error in
            print(error)
            XCTAssert(error is IdentifierError)
            
            guard let identifierError = error as? IdentifierError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "verified_id_creation_error")
            XCTAssertEqual(identifierError.message, "Unable to create self signed Verified ID.")
            XCTAssertEqual(identifierError.error as? MockSigner.ExpectedError,
                           MockSigner.ExpectedError.SignExpectedToThrow)
        }
    }
    
    func testCreatedSelfSignedVerifiedId_WhenValidInput_ReturnsVerifiedId() async throws
    {
        // Arrange
        let mockIdentifierManager = MockIdentifierManager(mockKeyId: "mockKeyId")
        let config = LibraryConfiguration()
        let mockSigner = MockSigner(doesSignThrow: false)
        let extensionIdentifierManager = InternalExtensionIdentifierManager(identifierManager: mockIdentifierManager,
                                                                            libraryConfiguration: config,
                                                                            tokenSigner: mockSigner)
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
