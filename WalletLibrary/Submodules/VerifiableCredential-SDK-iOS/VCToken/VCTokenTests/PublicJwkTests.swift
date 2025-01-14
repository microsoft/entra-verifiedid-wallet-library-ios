/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import WalletLibrary

@testable import WalletLibrary

class PublicJWKTests: XCTestCase {
    
    var jwk: PublicJWK!
    
    let expectedX = "8ZHxJnpwFHDQHLHFZeioQF28zfOxiFL_20TZ6MDwNHA"
    let expectedY = "6wmlF367mhEAcwpzcP9P7eEP2Kfj3Arg72Pl1NtYBoI"
    let expectedCurve = "secp256k1"
    let expectedKid = "testKid"
    let expectedThumbprint = "RVdKoNzlIODuzv1J2zpIyGqTsMHkPesOBDbWx9kOCFk"
    
    override func setUpWithError() throws {
        jwk = PublicJWK(x: expectedX,
                        y: expectedY,
                        keyType: "EC",
                        keyId: expectedKid,
                        algorithm: "ES256K",
                        curve: expectedCurve)
    }
    
    func testInit() throws
    {
        self.checkProperties(of: jwk)
    }
    
    func testInitFromSecp256k1PublicKey() throws {
        let x = Data(base64URLEncoded: expectedX)!
        print(x.count)
        
        let y = Data(base64URLEncoded: expectedY)!
        print(y.count)
        
        let key = Secp256k1PublicKey(x: x, y: y)
        
        let jwt = PublicJWK(withPublicKey: key!, withKeyId: expectedKid)
        self.checkProperties(of: jwt)
    }
    
    func testGetThumbprint() throws {
        let actualThumbprint = try jwk.getThumbprint()
        XCTAssertEqual(actualThumbprint, expectedThumbprint)
    }
    
    func checkProperties(of key: PublicJWK) {
        XCTAssertEqual(key.x, expectedX)
        XCTAssertEqual(key.y, expectedY)
        XCTAssertEqual(key.keyId, expectedKid)
        XCTAssertEqual(key.algorithm, "ES256K")
        XCTAssertEqual(key.curve, "secp256k1")
        XCTAssertEqual(key.keyOperations, ["verify"])
        XCTAssertEqual(key.keyType, "EC")
        XCTAssertEqual(key.use, "sig")
    }
}
