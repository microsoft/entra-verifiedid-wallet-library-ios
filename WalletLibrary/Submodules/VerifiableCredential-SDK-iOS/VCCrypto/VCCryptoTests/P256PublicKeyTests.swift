/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class P256PublicKeyTests: XCTestCase {
    
    func testPublicKeyFromUncompressedData() {
        // Arrange
        // Create a byte array representation of an uncompressed public key
        let x = Data(hexString: "6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296")
        let y = Data(hexString: "4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5")
        
        var uncompressedPublicKey = Data()
        uncompressedPublicKey.append(x)
        uncompressedPublicKey.append(y)
        
        // Act
        let publicKey = P256PublicKey(uncompressedPublicKey: uncompressedPublicKey)!
        
        // Assert
        XCTAssertEqual(publicKey.x, x)
        XCTAssertEqual(publicKey.y, y)
    }
    
    func testPublicKeyFromCoordinates() {
        // Arrange
        // Create a byte array representation of an uncompressed public key
        let x = Data(hexString: "7CF27B188D034F7E8A52380304B51AC3C08969E277F21B35A60B48FC47669978")
        let y = Data(hexString: "07775510DB8ED040293D9AC69F7430DBBA7DADE63CE982299E04B79D227873D1")
        
        // Act
        let publicKey = P256PublicKey(x: x, y: y)!
        
        // Assert
        XCTAssertEqual(publicKey.x, x)
        XCTAssertEqual(publicKey.y, y)
    }
    
    func testInvalidPublicKey () {
        // Arrange / Act
        let publicKey = P256PublicKey(uncompressedPublicKey: Data(repeating: 1, count: 65))
        
        // Assert
        XCTAssertNil(publicKey)
    }
}
