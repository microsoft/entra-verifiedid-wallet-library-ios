/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import VCCrypto

class ES256kTests: XCTestCase {
    
    override func setUpWithError() throws {
        HashingMock.wasHashCalled = false
        SigningMock.wasSignCalled = false
        SigningMock.wasCreatePublicKeyCalled = false
        SigningMock.wasIsValidSignatureCalled = false
    }
    
    func testIsValidSignature() throws {
        
        let signature = Data(count: 32)
        let hash = Data(count: 32)
        let publicKey = PublicKeyMock()
        
        let hashingAlgo = HashingMock()
        let signingAlgo = SigningMock(isValidSignatureResult: true)
        
        let algo = ES256k(hashAlgorithm: hashingAlgo, curveAlgorithm: signingAlgo)
        let result = try algo.isValidSignature(signature: signature, forMessage: hash, usingPublicKey: publicKey)
        XCTAssertTrue(HashingMock.wasHashCalled)
        XCTAssertTrue(SigningMock.wasIsValidSignatureCalled)
        XCTAssertTrue(result)
    }
    
    func testInvalidSignature() throws {
        
        let signature = Data(count: 32)
        let hash = Data(count: 32)
        let publicKey = PublicKeyMock()
        
        let hashingAlgo = HashingMock()
        let signingAlgo = SigningMock(isValidSignatureResult: false)
        
        let algo = ES256k(hashAlgorithm: hashingAlgo, curveAlgorithm: signingAlgo)
        let result = try algo.isValidSignature(signature: signature, forMessage: hash, usingPublicKey: publicKey)
        XCTAssertTrue(HashingMock.wasHashCalled)
        XCTAssertTrue(SigningMock.wasIsValidSignatureCalled)
        XCTAssertFalse(result)
    }
    
    func testSign() throws {
        
        let hash = Data(count: 32)
        let secret = SecretMock(id: UUID(), withData: Data(count: 32))

        let expectedResult = Data(count: 32)
        let hashingAlgo = HashingMock(hashingResult: expectedResult)
        let signingAlgo = SigningMock(signingResult: expectedResult)
        
        let algo = ES256k(hashAlgorithm: hashingAlgo, curveAlgorithm: signingAlgo)
        let signature = try algo.sign(message: hash, withSecret: secret)
        XCTAssertTrue(HashingMock.wasHashCalled)
        XCTAssertTrue(SigningMock.wasSignCalled)
        XCTAssertEqual(signature, expectedResult)
    }
    
    func testCreatePublicKey() throws {
        
        let secret = SecretMock(id: UUID(), withData: Data(count: 32))

        let expectedPublicKey = PublicKeyMock()
        let signingAlgo = SigningMock(createPublicKeyResult: expectedPublicKey)
        
        let algo = ES256k(curveAlgorithm: signingAlgo)
        let publicKey = try algo.createPublicKey(forSecret: secret) as? PublicKeyMock
        XCTAssertEqual(publicKey, expectedPublicKey)
        XCTAssertTrue(SigningMock.wasCreatePublicKeyCalled)
    }
}
