/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class JwsTokenExtensionTests: XCTestCase
{
    func testGetKeyId_WithEmptyKid_ReturnsNil() throws
    {
        // Arrange
        let headers = Header(keyId: "")
        let token = JwsToken(headers: headers, content: MockClaims(key: ""))!
        
        // Act / Assert
        XCTAssertNil(token.getKeyId())
    }
    
    func testGetKeyId_WithKid_ReturnsKeyId() throws
    {
        // Arrange
        let expectedDid = "did:test:mock"
        let expectedKeyId = "mockKeyId"
        let headers = Header(keyId: "\(expectedDid)#\(expectedKeyId)")
        let token = JwsToken(headers: headers, content: MockClaims(key: ""))!
        
        // Act
        let keyId = token.getKeyId()
        
        // Assert
        XCTAssertEqual(expectedDid, keyId?.did)
        XCTAssertEqual(expectedKeyId, keyId?.keyId)
    }
    
    func testValidateExpAndIat_WithValidateProps_DoesNotThrow() throws
    {
        // Arrange
        let exp = (Date().timeIntervalSince1970).rounded(.down)
        let iat = (Date().timeIntervalSince1970).rounded(.down)
        let claims = MockClaims(key: "", iat: iat, exp: exp)
        let token = JwsToken(headers: Header(), content: claims)!
        
        // Act / Assert
        XCTAssertNoThrow(try token.validateIatAndExp())
    }
    
    func testValidateExpAndIat_WithExpiredToken_DoesThrows() throws
    {
        // Arrange
        let exp = (Date().timeIntervalSince1970).rounded(.down) - 6000
        let iat = (Date().timeIntervalSince1970).rounded(.down)
        let claims = MockClaims(key: "", iat: iat, exp: exp)
        let token = JwsToken(headers: Header(), content: claims)!
        
        // Act / Assert
        XCTAssertThrowsError(try token.validateIatAndExp()) { error in
            XCTAssert(error is TokenValidationError)
            XCTAssertEqual((error as? TokenValidationError)?.message, "Token has expired.")
            XCTAssertEqual((error as? TokenValidationError)?.code, "token_expired")
        }
    }
    
    func testValidateExpAndIat_WithInvalidIat_DoesThrows() throws
    {
        // Arrange
        let exp = (Date().timeIntervalSince1970).rounded(.down)
        let iat = (Date().timeIntervalSince1970).rounded(.down) + 6000
        let claims = MockClaims(key: "", iat: iat, exp: exp)
        let token = JwsToken(headers: Header(), content: claims)!
        
        // Act / Assert
        XCTAssertThrowsError(try token.validateIatAndExp()) { error in
            XCTAssert(error is TokenValidationError)
            XCTAssertEqual((error as? TokenValidationError)?.message,
                           "Token iat has not occurred.")
            XCTAssertEqual((error as? TokenValidationError)?.code,
                           "token_invalid")
        }
    }
    
    func testValidateExpAndIat_WithMissingIat_DoesThrows() throws
    {
        // Arrange
        let exp = (Date().timeIntervalSince1970).rounded(.down)
        let claims = MockClaims(key: "", exp: exp)
        let token = JwsToken(headers: Header(), content: claims)!
        
        // Act / Assert
        XCTAssertThrowsError(try token.validateIatAndExp()) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: "iat",
                                                                       in: "MockClaims"))
        }
    }
    
    func testValidateExpAndIat_WithMissingExp_DoesThrows() throws
    {
        // Arrange
        let iat = (Date().timeIntervalSince1970).rounded(.down)
        let claims = MockClaims(key: "", iat: iat)
        let token = JwsToken(headers: Header(), content: claims)!
        
        // Act / Assert
        XCTAssertThrowsError(try token.validateIatAndExp()) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: "exp",
                                                                       in: "MockClaims"))
        }
    }
    
}
