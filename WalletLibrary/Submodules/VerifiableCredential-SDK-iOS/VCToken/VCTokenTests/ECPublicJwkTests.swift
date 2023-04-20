/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCCrypto

@testable import VCToken

class ECPublicJwkTests: XCTestCase {
    
    var jwk: ECPublicJwk!
    
    let expectedX = "8ZHxJnpwFHDQHLHFZeioQF28zfOxiFL_20TZ6MDwNHA"
    let expectedY = "6wmlF367mhEAcwpzcP9P7eEP2Kfj3Arg72Pl1NtYBoI"
    let expectedCurve = "secp256k1"
    let expectedKid = "testKid"
    let expectedThumbprint = "RVdKoNzlIODuzv1J2zpIyGqTsMHkPesOBDbWx9kOCFk"
    
    override func setUpWithError() throws {
        jwk = ECPublicJwk(x: expectedX, y: expectedY, keyId: expectedKid)
    }
    
    func testInit() throws {
        let jwk = ECPublicJwk(x: expectedX, y: expectedY, keyId: expectedKid)
        self.checkProperties(of: jwk)
    }
    
    func testInitFromSecp256k1PublicKey() throws {
        let x = Data(base64URLEncoded: expectedX)!
        print(x.count)
        
        let y = Data(base64URLEncoded: expectedY)!
        print(y.count)
        
        let key = Secp256k1PublicKey(x: x, y: y)
        
        let jwt = ECPublicJwk(withPublicKey: key!, withKeyId: expectedKid)
        self.checkProperties(of: jwt)
    }
    
    func testGetThumbprint() throws {
        let actualThumbprint = try jwk.getThumbprint()
        XCTAssertEqual(actualThumbprint, expectedThumbprint)
    }
    
    func checkProperties(of key: ECPublicJwk) {
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
