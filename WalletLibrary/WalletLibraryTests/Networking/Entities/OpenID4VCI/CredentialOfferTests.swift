/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class CredentialOfferTests: XCTestCase
{
    private let expectedCredentialIssuer = "https://microsoft.com/test"
    
    private let expectedIssuerSession = "eyJhbGciOiJSU0Et...FYUaBy"
    
    private let expectedCredentialIds = [ "1e699bec-3cdf-412a-a52e-7680d8edb5f0" ]
    
    private let expectedAuthorizationServer = "auth server"
    
    private let expectedPreAuthCode = "pre auth code"
    
    private let mapper = Mapper()
    
    func testMapping_WhenSuccessful_ReturnCredentialOffer() async throws
    {
        // Arrange
        let jsonCredentialOffer = createJSONAccessTokenCredentialOffer()
        
        // Act
        let result = try mapper.map(jsonCredentialOffer, type: CredentialOffer.self)
        
        // Assert
        XCTAssertEqual(expectedCredentialIssuer, result.credential_issuer)
        XCTAssertEqual(expectedIssuerSession, result.issuer_session)
        XCTAssertEqual(expectedCredentialIds, result.credential_configuration_ids)
        XCTAssertEqual(expectedAuthorizationServer, result.grants["authorization_code"]?.authorization_server)
    }
    
    func testMapping_WhenMissingProperties_ThrowError() async throws
    {
        // Arrange
        let jsonCredentialOffer = createJSONAccessTokenCredentialOffer()
        
        let keys = jsonCredentialOffer.keys
        
        for key in keys
        {
            var missingKeyCredentialOffer = jsonCredentialOffer
            missingKeyCredentialOffer.removeValue(forKey: key)
            
            // Act / Assert
            XCTAssertThrowsError(try mapper.map(missingKeyCredentialOffer, type: CredentialOffer.self))
            { error in
                
                XCTAssert(error is MappingError)
                XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: key,
                                                                           in: "CredentialOffer"))
            }
        }
    }
    
    func testMapping_WhenGrantsEmpty_ThrowError() async throws
    {
        // Arrange
        var jsonCredentialOffer = createJSONAccessTokenCredentialOffer()
        jsonCredentialOffer["grants"] = []
        
        // Act / Assert
        XCTAssertThrowsError(try mapper.map(jsonCredentialOffer, type: CredentialOffer.self))
        { error in
            
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: "grants",
                                                                       in: "CredentialOffer"))
        }
    }
    
    func testMapping_WithPreAuthProperties_ReturnCredentialOffer() async throws
    {
        // Arrange
        let txCode: [String: Any] = [
            "length": 6,
            "input_mode": "numeric"
        ]
        let jsonCredentialOffer = createJSONPreAuthCredentialOffer(txCode: txCode)
        
        // Act
        let result = try mapper.map(jsonCredentialOffer, type: CredentialOffer.self)
        
        // Assert
        XCTAssertEqual(expectedCredentialIssuer, result.credential_issuer)
        XCTAssertEqual(expectedIssuerSession, result.issuer_session)
        XCTAssertEqual(expectedCredentialIds, result.credential_configuration_ids)
        XCTAssertEqual(expectedAuthorizationServer,
                       result.grants["authorization_code"]?.authorization_server)
        XCTAssertEqual(expectedPreAuthCode, 
                       result.grants["authorization_code"]?.pre_authorized_code)
        XCTAssertEqual("numeric",
                       result.grants["authorization_code"]?.tx_code?.input_mode)
        XCTAssertEqual(6,
                       result.grants["authorization_code"]?.tx_code?.length)
        
    }
    
    func testMapping_WhenLengthInTxCodeMissing_ThrowError() async throws
    {
        // Arrange
        let jsonCredentialOffer = createJSONPreAuthCredentialOffer(txCode: ["input_mode": "numeric"])
        
        // Act / Assert
        XCTAssertThrowsError(try mapper.map(jsonCredentialOffer, type: CredentialOffer.self))
        { error in
            
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: "length",
                                                                       in: "CredentialOfferGrantCode"))
        }
    }
    
    func testMapping_WhenInputModeInTxCodeEmpty_ThrowError() async throws
    {
        // Arrange
        let jsonCredentialOffer = createJSONPreAuthCredentialOffer(txCode: ["length": 6])
        
        // Act / Assert
        XCTAssertThrowsError(try mapper.map(jsonCredentialOffer, type: CredentialOffer.self))
        { error in
            
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: "input_mode",
                                                                       in: "CredentialOfferGrantCode"))
        }
    }
    
    private func createJSONAccessTokenCredentialOffer() -> [String: Any]
    {
        let json: [String: Any] = [
            "credential_issuer": expectedCredentialIssuer,
            "issuer_session": expectedIssuerSession,
            "credential_configuration_ids": expectedCredentialIds,
            "grants": [
                "authorization_code": [
                    "authorization_server": expectedAuthorizationServer
                ]
            ]
        ]
        
        return json
    }
    
    private func createJSONPreAuthCredentialOffer(txCode: [String: Any]) -> [String: Any]
    {
        let json: [String: Any] = [
            "credential_issuer": expectedCredentialIssuer,
            "issuer_session": expectedIssuerSession,
            "credential_configuration_ids": expectedCredentialIds,
            "grants": [
                "authorization_code": [
                    "authorization_server": expectedAuthorizationServer,
                    "pre-authorized_code": expectedPreAuthCode,
                    "tx_code": txCode
                ]
            ]
        ]
        
        return json
    }
}
