/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import VCCrypto

class Secp256k1Tests: XCTestCase {
    
    func testIsValidSignature() throws {
        
        let x = Data(base64URLEncoded: "r_1voElsuJnWrc7MLzqKeIQ2ZrlXP3UDfOYclKMvJWg")!
        let y = Data(base64URLEncoded: "-uYArMDYDpxaQ8_z9s1kGzToHPHvxORah_V_rhsLoEU")!
        
        let publicKey = Secp256k1PublicKey(x: x, y: y)!
        
        let hash = Data(hexString: "85EB4467104FBD9883BF4075EC79DEFDC6EC260B2898D4B4D195443C463B0ED3")
        let signature = Data(hexString: "6C35A6C0F0BE1858DA4275DD60E69EA174E20B3D6E66FD9E4A9C385BEE7F1DD12054DED0D1E5DED54F763C3B468333EE2E1116E8AE22A51A0FF521A0EBBE3C62")
        
        let algo = Secp256k1()
        let result = try algo.isValidSignature(signature: signature, forMessage: hash, usingPublicKey: publicKey)
        XCTAssertTrue(result)
    }
    
    func testInvalidSignature() throws {
        
        let x = Data(base64URLEncoded: "r_1voElsuJnWrc7MLzqKeIQ2ZrlXP3UDfOYclKMvJWg")!
        let y = Data(base64URLEncoded: "-uYArMDYDpxaQ8_z9s1kGzToHPHvxORah_V_rhsLoEU")!
        
        let publicKey = Secp256k1PublicKey(x: x, y: y)!
        
        let hash = Data(hexString: "85EB4467104FBD9883BF4075EC79DEFDC6EC260B2898D4B4D195443C463B0ED3")
        let signature = Data(hexString: "ABCDA6C0F0BE1858DA4275DD60E69EA174E20B3D6E66FD9E4A9C385BEE7F1DD12054DED0D1E5DED54F763C3B468333EE2E1116E8AE22A51A0FF521A0EBBE3C62")
        
        let algo = Secp256k1()
        let result = try algo.isValidSignature(signature: signature, forMessage: hash, usingPublicKey: publicKey)
        XCTAssertFalse(result)
    }
    
    func testSign() throws {
        let secretStoreMock: SecretStoreMock = SecretStoreMock()
        let secret = try Random32BytesSecret(withStore: secretStoreMock)
        let hash = Data(repeating: 1, count: 32)
        let algo = Secp256k1()
        let signature = try algo.sign(message: hash, withSecret: secret)
        let publicKey = try algo.createPublicKey(forSecret: secret)
        
        let result = try algo.isValidSignature(signature: signature, forMessage: hash, usingPublicKey: publicKey)
        XCTAssert(result)
    }
}
