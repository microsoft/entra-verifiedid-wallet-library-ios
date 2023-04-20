/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import VCCrypto

class Secp256k1PublicKeyTests: XCTestCase {
    
    func testPublicKeyFromUncompressedData() {
    
        // Create a byte array representation of an uncompressed public key
        let x = Data(base64URLEncoded: "r_1voElsuJnWrc7MLzqKeIQ2ZrlXP3UDfOYclKMvJWg")!
        let y = Data(base64URLEncoded: "-uYArMDYDpxaQ8_z9s1kGzToHPHvxORah_V_rhsLoEU")!
        
        var uncompressedPublicKey = Data()
        uncompressedPublicKey.append(4)
        uncompressedPublicKey.append(x)
        uncompressedPublicKey.append(y)
        
        let publicKey = Secp256k1PublicKey(uncompressedPublicKey: uncompressedPublicKey)!
        
        XCTAssertEqual(publicKey.x, x)
        XCTAssertEqual(publicKey.y, y)
    }
    
    func testPublicKeyFromCoordinates() {
    
        // Create a byte array representation of an uncompressed public key
        let x = Data(base64URLEncoded: "r_1voElsuJnWrc7MLzqKeIQ2ZrlXP3UDfOYclKMvJWg")!
        let y = Data(base64URLEncoded: "-uYArMDYDpxaQ8_z9s1kGzToHPHvxORah_V_rhsLoEU")!
        
        let publicKey = Secp256k1PublicKey(x: x, y: y)!
        
        XCTAssertEqual(publicKey.x, x)
        XCTAssertEqual(publicKey.y, y)
    }
    
    func testInvalidPublicKey () {
        let publicKey = Secp256k1PublicKey(uncompressedPublicKey: Data(repeating: 1, count: 64))
        XCTAssertNil(publicKey)
    }
}
