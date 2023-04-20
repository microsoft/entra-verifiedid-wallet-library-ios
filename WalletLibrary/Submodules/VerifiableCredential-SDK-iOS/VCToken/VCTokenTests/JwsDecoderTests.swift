/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCToken

class JwsDecoderTests: XCTestCase {
    
    private let decoder = JwsDecoder()
    private var testToken: JwsToken<MockClaims>!
    private let expectedSignature = "fakeSignature".data(using: .utf8)
    private let expectedHeader = Header(keyId: "test")
    private let expectedContent = MockClaims(key: "value67")
    private let jsonDecoder = JSONDecoder()
    private let encodedHeader = "eyJraWQiOiJ0ZXN0In0"
    private let encodedContent = "eyJrZXkiOiJ2YWx1ZTY3In0"
    

    override func setUpWithError() throws {
        testToken = JwsToken(headers: expectedHeader, content: expectedContent, signature: expectedSignature)
    }

    func testDecodeTokenNoSignature() throws {
        let compactToken = encodedHeader + "." + encodedContent
        let result = try decoder.decode(MockClaims.self, token: compactToken)
        print(result.content)
        
        XCTAssertEqual(result.content, expectedContent)
        XCTAssertEqual(result.headers.keyId, expectedHeader.keyId)
        XCTAssertNil(result.signature)
    }
    
    func testDecodeSignedToken() throws {
        let base64UrlSignature = expectedSignature!.base64URLEncodedString()
        let compactToken = encodedHeader + "." + encodedContent + "." + base64UrlSignature
        let result = try decoder.decode(MockClaims.self, token: compactToken)
        
        XCTAssertEqual(result.content, expectedContent)
        XCTAssertEqual(result.headers.keyId, expectedHeader.keyId)
        XCTAssertEqual(result.signature, expectedSignature)
    }
    
    func testMalformedToken() throws {
        let compactToken = encodedHeader
        XCTAssertThrowsError(try decoder.decode(MockClaims.self, token: compactToken))
    }
    
    func testMalformedHeader() throws {
        let compactToken = "+." + encodedContent + "."
        XCTAssertThrowsError(try decoder.decode(MockClaims.self, token: compactToken))
    }
    
    func testMalformedContent() throws {
        let compactToken = encodedHeader + ".+."
        XCTAssertThrowsError(try decoder.decode(MockClaims.self, token: compactToken))
    }
}
