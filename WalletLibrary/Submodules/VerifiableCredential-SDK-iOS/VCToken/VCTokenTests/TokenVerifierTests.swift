/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCToken

class TokenVerifierTests: XCTestCase {
    
    private var testToken: JwsToken<MockClaims>!
    private var expectedResult: Data!
    private let expectedHeader = Header(algorithm: "ES256K", keyId: "test")
    private let expectedContent = MockClaims(key: "value67")

    override func setUpWithError() throws {
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: nil)
        expectedResult = testToken.protectedMessage.data(using: .utf8)!
        MockCryptoOperations.wasVerifyCalled = false
        MockCryptoOperations.wasSignCalled = false
        MockCryptoOperations.wasGetPublicKeyCalled = false
    }
    
    func testVerifierWithNoSignature() throws {
        let verifier = TokenVerifier(cryptoOperations: MockCryptoOperations())
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: nil)
        let publicKey = JWK(keyType: "testType",
                            keyId: nil,
                            key: nil,
                            curve: nil,
                            use: nil,
                            x: Data(count: 32),
                            y: Data(count: 32),
                            d: nil)
        let result = try verifier.verify(token: testToken, usingPublicKey: publicKey)
        XCTAssertFalse(result)
        XCTAssertFalse(MockCryptoOperations.wasVerifyCalled)
    }
    
    func testVerifierWithMalformedProtectedMessage() throws {
        let verifier = TokenVerifier(cryptoOperations: MockCryptoOperations())
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, protectedMessage: "¼¡©", signature: "testSignature".data(using: .utf8))
        let publicKey = JWK(keyType: "testType",
                            keyId: nil,
                            key: nil,
                            curve: "secp256k1",
                            use: nil,
                            x: Data(count: 32),
                            y: Data(count: 32),
                            d: nil)
        XCTAssertThrowsError(try verifier.verify(token: testToken, usingPublicKey: publicKey)) { error in
            XCTAssertFalse(MockCryptoOperations.wasVerifyCalled)
            XCTAssertEqual(error as? TokenVerifierError, TokenVerifierError.malformedProtectedMessageInToken)
        }
    }
    
    func testVerifierWithMalformedJWKForED25519() throws {
        let verifier = TokenVerifier(cryptoOperations: MockCryptoOperations())
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: "testSignature".data(using: .utf8))
        let publicKey = JWK(keyType: "testType",
                            keyId: nil,
                            key: nil,
                            curve: "secp256k1",
                            use: nil,
                            x: nil,
                            y: nil,
                            d: nil)
        XCTAssertThrowsError(try verifier.verify(token: testToken, usingPublicKey: publicKey)) { error in
            XCTAssertFalse(MockCryptoOperations.wasVerifyCalled)
            XCTAssertEqual(error as? TokenVerifierError, TokenVerifierError.missingKeyMaterialInJWK)
        }
    }
    
    func testVerifierWithMalformedJWKForSECP256K1() throws {
        let verifier = TokenVerifier(cryptoOperations: MockCryptoOperations())
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: "testSignature".data(using: .utf8))
        let publicKey = JWK(keyType: "testType",
                            keyId: nil,
                            key: nil,
                            curve: "secp256k1",
                            use: nil,
                            x: Data(count: 32),
                            y: nil,
                            d: nil)
        XCTAssertThrowsError(try verifier.verify(token: testToken, usingPublicKey: publicKey)) { error in
            XCTAssertFalse(MockCryptoOperations.wasVerifyCalled)
            XCTAssertEqual(error as? TokenVerifierError, TokenVerifierError.missingKeyMaterialInJWK)
        }
    }
    
    func testVerifierWithUnsupportedAlgorithmError() throws {
        let verifier = TokenVerifier(cryptoOperations: MockCryptoOperations())
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: "testSignature".data(using: .utf8))
        let publicKey = JWK(keyType: "testType",
                            keyId: nil,
                            key: nil,
                            curve: "unsupportedCurve",
                            use: nil,
                            x: Data(count: 32),
                            y: nil,
                            d: nil)
        XCTAssertThrowsError(try verifier.verify(token: testToken, usingPublicKey: publicKey)) { error in
            XCTAssertFalse(MockCryptoOperations.wasVerifyCalled)
            XCTAssertEqual(error as? TokenVerifierError, TokenVerifierError.unsupportedAlgorithmFoundInJWK(algorithm: "unsupportedCurve"))
        }
    }
    
    func testVerifierWithSignatureWithPublicKey() throws {
        let verifier = TokenVerifier(cryptoOperations: MockCryptoOperations())
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: "testSignature".data(using: .utf8))
        let publicKey = JWK(keyType: "testType",
                            keyId: nil,
                            key: nil,
                            curve: "secp256k1",
                            use: nil,
                            x: Data(count: 32),
                            y: Data(count: 32),
                            d: nil)
        let result = try verifier.verify(token: testToken, usingPublicKey: publicKey)
        XCTAssertTrue(result)
        XCTAssertTrue(MockCryptoOperations.wasVerifyCalled)
    }
    
    func testVerifierWithSignatureWithInvalidSignature() throws {
        let verifier = TokenVerifier(cryptoOperations: MockCryptoOperations(verifyResult: false))
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: "testSignature".data(using: .utf8))
        let publicKey = JWK(keyType: "testType",
                            keyId: nil,
                            key: nil,
                            curve: "secp256k1",
                            use: nil,
                            x: Data(count: 32),
                            y: Data(count: 32),
                            d: nil)
        let result = try verifier.verify(token: testToken, usingPublicKey: publicKey)
        XCTAssertFalse(result)
        XCTAssertTrue(MockCryptoOperations.wasVerifyCalled)
    }
}
