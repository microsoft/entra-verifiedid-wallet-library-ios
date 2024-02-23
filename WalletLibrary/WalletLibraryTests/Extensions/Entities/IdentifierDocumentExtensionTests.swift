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
        let wrongId = "wrong id"
        let publicKey = createPublicKey(id: "mock id")
        let document = IdentifierDocument(service: nil,
                                          verificationMethod: [publicKey], 
                                          authentication: [],
                                          id: "mock document")
        
        // Act / Assert
        XCTAssertNil(document.getJWK(id: wrongId))
    }
    
    func testGetJWK_WithOnePublicKey_ReturnJWK() throws
    {
        // Arrange
        let id = "mock id"
        let publicKey = createPublicKey(id: id)
        let document = IdentifierDocument(service: nil,
                                          verificationMethod: [publicKey],
                                          authentication: [],
                                          id: "mock document")
        
        // Act
        let result = document.getJWK(id: id)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result, publicKey.publicKeyJwk.toJWK())
    }
    
    func testGetJWK_WithMultiplePublicKeys_ReturnJWK() throws
    {
        // Arrange
        let id = "mock id"
        let publicKey1 = createPublicKey(id: id)
        let publicKey2 = createPublicKey(id: "extraKey1")
        let publicKey3 = createPublicKey(id: "extraKey2")
        let document = IdentifierDocument(service: nil,
                                          verificationMethod: [publicKey1,
                                                               publicKey2,
                                                               publicKey3],
                                          authentication: [],
                                          id: "mock document")
        
        // Act
        let result = document.getJWK(id: id)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result, publicKey1.publicKeyJwk.toJWK())
        XCTAssertNotEqual(result, publicKey2.publicKeyJwk.toJWK())
        XCTAssertNotEqual(result, publicKey3.publicKeyJwk.toJWK())
    }
    
    private func createPublicKey(id: String) -> IdentifierDocumentPublicKey
    {
        let secpKey = Secp256k1PublicKey(x: Data(count: 32), y: Data(count: 32))!
        let publicJwk = ECPublicJwk(withPublicKey: secpKey, withKeyId: id)
        let publicKey = IdentifierDocumentPublicKey(id: id,
                                                    type: "mock",
                                                    controller: nil,
                                                    publicKeyJwk: publicJwk,
                                                    purposes: nil)
        return publicKey
    }
}

