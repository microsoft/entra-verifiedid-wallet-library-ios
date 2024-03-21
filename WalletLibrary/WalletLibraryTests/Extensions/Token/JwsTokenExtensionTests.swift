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
        let expectedKeyId = "#mockKeyId"
        let headers = Header(keyId: "\(expectedDid)\(expectedKeyId)")
        let token = JwsToken(headers: headers, content: MockClaims(key: ""))!
        
        // Act
        let keyId = token.getKeyId()
        
        // Assert
        XCTAssertEqual(expectedDid, keyId?.did)
        XCTAssertEqual(expectedKeyId, keyId?.keyId)
    }
    
    func testValidateExp_WithValidateProps_DoesNotThrow() throws
    {
        // Arrange
        let exp = Int((Date().timeIntervalSince1970).rounded(.down))
        let iat = Int((Date().timeIntervalSince1970).rounded(.down))
        let claims = MockClaims(key: "", iat: iat, exp: exp)
        let token = JwsToken(headers: Header(), content: claims)!
        
        // Act / Assert
        XCTAssertNoThrow(try token.validateExpIfPresent())
    }
    
    func testValidateExp_WithExpiredToken_DoesThrows() throws
    {
        // Arrange
        let exp = Int((Date().timeIntervalSince1970).rounded(.down) - 6000)
        let iat = Int((Date().timeIntervalSince1970).rounded(.down))
        let claims = MockClaims(key: "", iat: iat, exp: exp)
        let token = JwsToken(headers: Header(), content: claims)!
        
        // Act / Assert
        XCTAssertThrowsError(try token.validateExpIfPresent()) { error in
            XCTAssert(error is TokenValidationError)
            XCTAssertEqual((error as? TokenValidationError)?.message, "Token has expired.")
            XCTAssertEqual((error as? TokenValidationError)?.code, "token_expired")
        }
    }
    
    func testValidateIat_WithInvalidIat_DoesThrows() throws
    {
        // Arrange
        let exp = Int((Date().timeIntervalSince1970).rounded(.down))
        let iat = Int((Date().timeIntervalSince1970).rounded(.down) + 6000)
        let claims = MockClaims(key: "", iat: iat, exp: exp)
        let token = JwsToken(headers: Header(), content: claims)!
        
        // Act / Assert
        XCTAssertThrowsError(try token.validateIatIfPresent()) { error in
            XCTAssert(error is TokenValidationError)
            XCTAssertEqual((error as? TokenValidationError)?.message,
                           "Token iat has not occurred.")
            XCTAssertEqual((error as? TokenValidationError)?.code,
                           "token_invalid")
        }
    }
    
    func testValidateIat_WithMissingIat_DoesNotThrows() throws
    {
        // Arrange
        let exp = Int((Date().timeIntervalSince1970).rounded(.down))
        let claims = MockClaims(key: "", exp: exp)
        let token = JwsToken(headers: Header(), content: claims)!
        
        // Act / Assert
        XCTAssertNoThrow(try token.validateIatIfPresent())
    }
    
    func testValidateExp_WithMissingExp_DoesThrows() throws
    {
        // Arrange
        let iat = Int((Date().timeIntervalSince1970).rounded(.down))
        let claims = MockClaims(key: "", iat: iat)
        let token = JwsToken(headers: Header(), content: claims)!
        
        // Act / Assert
        XCTAssertNoThrow(try token.validateExpIfPresent())
    }
    
}
