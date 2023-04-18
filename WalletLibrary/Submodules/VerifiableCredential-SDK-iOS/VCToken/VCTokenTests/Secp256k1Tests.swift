/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import VCToken
import XCTest
import VCCrypto

class Secp256k1Tests: XCTestCase {
    
    private var testToken: JwsToken<MockClaims>!
    private var expectedResult: Data!
    private let expectedHeader = Header(algorithm: "ES256K", keyId: "test")
    private let expectedContent = MockClaims(key: "value67")

    override func setUpWithError() throws {
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: nil)
        let hashAlgorithm = Sha256()
        let protectedMessage = testToken.protectedMessage.data(using: .utf8)!
        expectedResult = hashAlgorithm.hash(data: protectedMessage)
    }

    func testSigner() throws {
        let signer = Secp256k1Signer(cryptoOperations: MockCryptoOperations(signingResult: expectedResult))
        let mockSecret = MockVCCryptoSecret(id: UUID())
        let result = try signer.sign(token: testToken, withSecret: mockSecret)
        XCTAssertEqual(result, expectedResult)
    }
    
    func testGetPublicKey() throws {
        let expectedX = Data(count: 32)
        let expectedY = Data(count: 32)
        let expectedKeyId = "keyId354"
        let expectedPubKey = ECPublicJwk(x: expectedX.base64URLEncodedString(), y: expectedY.base64URLEncodedString(), keyId: expectedKeyId)
        let expectedPublicKey = Secp256k1PublicKey(x: expectedX, y: expectedY)!
        let signer = Secp256k1Signer(cryptoOperations: MockCryptoOperations(publicKey: expectedPublicKey))
        let mockSecret = MockVCCryptoSecret(id: UUID())
        let result = try signer.getPublicJwk(from: mockSecret, withKeyId: expectedKeyId)
        XCTAssertEqual(result.x, expectedPubKey.x)
        XCTAssertEqual(result.y, expectedPubKey.y)
        XCTAssertEqual(result.keyId, expectedPubKey.keyId)
    }
}
