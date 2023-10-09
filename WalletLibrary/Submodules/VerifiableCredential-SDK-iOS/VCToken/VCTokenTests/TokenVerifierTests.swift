/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest

@testable import WalletLibrary

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
    
    func testVerify_WithNoSignature_ReturnFalse() throws {
        // Arrange
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
        
        // Act
        let result = try verifier.verify(token: testToken, usingPublicKey: publicKey)
        
        // Assert
        XCTAssertFalse(result)
        XCTAssertFalse(MockCryptoOperations.wasVerifyCalled)
    }
    
    func testVerify_WithMalformedProtectedMessage_ThrowsError() throws {
        // Arrange
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
        
        // Act / Assert
        XCTAssertThrowsError(try verifier.verify(token: testToken, usingPublicKey: publicKey)) { error in
            XCTAssertFalse(MockCryptoOperations.wasVerifyCalled)
            XCTAssertEqual(error as? TokenVerifierError, TokenVerifierError.malformedProtectedMessageInToken)
        }
    }
    
    func testVerify_WithUnsupportedAlgorithm_ThrowsError() throws {
        // Arrange
        let verifier = TokenVerifier(cryptoOperations: MockCryptoOperations(throwWhenGettingPublicKey: true))
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: "testSignature".data(using: .utf8))
        let publicKey = JWK(keyType: "testType",
                            keyId: nil,
                            key: nil,
                            curve: "unsupportedCurve",
                            use: nil,
                            x: Data(count: 32),
                            y: nil,
                            d: nil)
        
        // Act / Assert
        XCTAssertThrowsError(try verifier.verify(token: testToken, usingPublicKey: publicKey)) { error in
            XCTAssertFalse(MockCryptoOperations.wasVerifyCalled)
            XCTAssertEqual(error as? MockCryptoError, MockCryptoError.ExpectedToThrow)
        }
    }
    
    func testVerify_WithValidSignatureAndPublicKey_ReturnsTrue() throws {
        // Arrange
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
        
        // Act
        let result = try verifier.verify(token: testToken, usingPublicKey: publicKey)
        
        // Assert
        XCTAssertTrue(result)
        XCTAssertTrue(MockCryptoOperations.wasVerifyCalled)
    }
    
    func testVerify_WithInvalidSignature_ReturnsTrue() throws {
        // Arrange
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
        
        // Act
        let result = try verifier.verify(token: testToken, usingPublicKey: publicKey)
        
        // Assert
        XCTAssertFalse(result)
        XCTAssertTrue(MockCryptoOperations.wasVerifyCalled)
    }
}
