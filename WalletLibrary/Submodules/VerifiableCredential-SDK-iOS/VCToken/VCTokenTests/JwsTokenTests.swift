/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import VCToken
import VCCrypto
import XCTest

class JwsTokenTests: XCTestCase {
    
    private var testToken: JwsToken<MockClaims>!
    private let expectedHeader = Header(keyId: "test")
    private let expectedContent = MockClaims(key: "value67")
    private let expectedSignature = "testSignature".data(using: .utf8)
    private let jsonDecoder = JSONDecoder()
    private let encodedHeader = "eyJraWQiOiJ0ZXN0In0"
    private let encodedContent = "eyJrZXkiOiJ2YWx1ZTY3In0"

    override func setUpWithError() throws {
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: expectedSignature)
    }

    func testInit() throws {
        XCTAssertEqual(testToken.content, expectedContent)
        XCTAssertEqual(testToken.headers.keyId, expectedHeader.keyId)
        XCTAssertEqual(testToken.signature, expectedSignature)
    }
    
    func testInitMalformedEncodedToken() throws {
        let encodedToken = "malformedToken"
        XCTAssertNil(JwsToken<MockClaims>(from: encodedToken))
    }
    
    func testInitMalformedEmptyString() throws {
        let encodedToken = ""
        XCTAssertNil(JwsToken<MockClaims>(from: encodedToken))
    }
    
    func testInitFromStringifiedToken() throws {
        let encoder = JwsEncoder()
        let encodedToken = try encoder.encode(testToken)
        let actualToken = JwsToken<MockClaims>(from: encodedToken)!
        XCTAssertEqual(actualToken.content, expectedContent)
        XCTAssertEqual(actualToken.headers.keyId, expectedHeader.keyId)
        XCTAssertEqual(actualToken.signature, expectedSignature)
    }
    
    func testInitFromDataToken() throws {
        let encoder = JwsEncoder()
        let encodedToken = try encoder.encode(testToken).data(using: .utf8)!
        let actualToken = JwsToken<MockClaims>(from: encodedToken)!
        XCTAssertEqual(actualToken.content, expectedContent)
        XCTAssertEqual(actualToken.headers.keyId, expectedHeader.keyId)
        XCTAssertEqual(actualToken.signature, expectedSignature)
    }
    
    func testSerialize() throws {
        let serializedToken = try testToken.serialize()
        let decoder = JwsDecoder()
        let actualToken = try decoder.decode(MockClaims.self, token: serializedToken)
        XCTAssertEqual(actualToken.content, expectedContent)
        XCTAssertEqual(actualToken.headers.keyId, expectedHeader.keyId)
        XCTAssertEqual(actualToken.signature, expectedSignature)
    }

    func testSigning() throws {
        var testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: nil)!
        let signer = MockSigner()
        let secret = MockVCCryptoSecret(id: UUID())
        try testToken.sign(using: signer, withSecret: secret)
        XCTAssertEqual(testToken.signature, "fakeSignature".data(using: .utf8)!)
    }
    
    func testVerifying() throws {
        let expectedHeader = Header(algorithm: "ES256K")
        let testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: Data.init(count: 64))
        let publicKey = JWK(keyType: "testType",
                            keyId: nil,
                            key: nil,
                            curve: nil,
                            use: nil,
                            x: Data(count: 32),
                            y: Data(count: 32),
                            d: nil)
        XCTAssertTrue(try testToken!.verify(using: MockVerifier(), withPublicKey: publicKey))
    }
    
    func testGetProtectedMessage() throws {
        let actualValue = testToken.protectedMessage
        let expectedValue = encodedHeader + "." + encodedContent
        XCTAssertEqual(actualValue, expectedValue)
    }

}
