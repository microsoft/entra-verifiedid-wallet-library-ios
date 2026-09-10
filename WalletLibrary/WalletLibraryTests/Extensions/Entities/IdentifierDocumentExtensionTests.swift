/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class IdentifierDocumentExtensionTests: XCTestCase {
    
    func testGetJWK_WithInvalidId_ReturnNil() throws
    {
        // Arrange
        let did = "did:test:mock"
        let wrongId = "#wrong-id"
        let publicKey = createPublicKey(id: "#key-id")
        let document = IdentifierDocument(service: nil,
                                          verificationMethod: [publicKey], 
                                          authentication: [],
                                          id: did)
        
        // Act / Assert
        XCTAssertNil(document.getJWK(id: wrongId, forDID: did, configuration: LibraryConfiguration()))
    }
    
    func testGetJWK_WithDefaultConfigurationAndNilDID_ReturnNil() throws
    {
        // Arrange
        let id = "#key-id"
        let publicKey = createPublicKey(id: id)
        let document = IdentifierDocument(service: nil,
                                          verificationMethod: [publicKey],
                                          authentication: [],
                                          id: "did:test:mock")
        
        // Act
        let result = document.getJWK(id: id, forDID: nil, configuration: LibraryConfiguration())
        
        // Assert
        XCTAssertNil(result)
    }
    
    func testGetJWK_WithDefaultConfiguration_ReturnsHardenedMatch() throws
    {
        // Arrange
        let did = "did:test:mock"
        let id = "#key-id"
        let publicKey = createPublicKey(id: id, controller: did)
        let document = IdentifierDocument(service: nil,
                                          verificationMethod: [publicKey],
                                          authentication: [],
                                          id: did)
        
        // Act
        let result = document.getJWK(id: id, forDID: did, configuration: LibraryConfiguration())
        
        // Assert
        XCTAssertEqual(result, publicKey.publicKeyJwk.toJWK())
    }

    func testGetJWK_WithDefaultConfigurationAndMismatchedController_ReturnNil() throws
    {
        // Arrange
        let did = "did:test:mock"
        let id = "#key-id"
        let publicKey = createPublicKey(id: id, controller: "did:test:attacker")
        let document = IdentifierDocument(service: nil,
                                          verificationMethod: [publicKey],
                                          authentication: [],
                                          id: did)

        // Act
        let result = document.getJWK(id: id, forDID: did, configuration: LibraryConfiguration())

        // Assert
        XCTAssertNil(result)
    }

    func testGetJWK_WithResolverHardeningDisabled_ReturnsLegacyIdMatch() throws
    {
        // Arrange
        let id = "#key-id"
        let publicKey = createPublicKey(id: id, controller: "did:test:attacker")
        let document = IdentifierDocument(service: nil,
                                          verificationMethod: [publicKey],
                                          authentication: [],
                                          id: "did:test:mock")
        let previewFeatureFlags = PreviewFeatureFlags(
            previewFeatureFlags: [PreviewFeatureFlags.DisableResolverHardening])
        let configuration = LibraryConfiguration(previewFeatureFlags: previewFeatureFlags)

        // Act
        let result = document.getJWK(id: id, forDID: nil, configuration: configuration)

        // Assert
        XCTAssertEqual(result, publicKey.publicKeyJwk.toJWK())
    }

    private func createPublicKey(id: String, controller: String? = nil) -> IdentifierDocumentPublicKey
    {
        let secpKey = Secp256k1PublicKey(x: Data(count: 32), y: Data(count: 32))!
        let publicJwk = PublicJWK(withPublicKey: secpKey, withKeyId: id)
        let publicKey = IdentifierDocumentPublicKey(id: id,
                                                    type: "mock",
                                                    controller: controller,
                                                    publicKeyJwk: publicJwk,
                                                    purposes: nil)
        return publicKey
    }
}
