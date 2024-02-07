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
    
    private let mapper = Mapper()
    
    func testMapping_WhenSuccessful_ReturnCredentialOffer() async throws
    {
        // Arrange
        let jsonCredentialOffer = createJSONCredentialOffer()
        
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
        let jsonCredentialOffer = createJSONCredentialOffer()
        
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
        var jsonCredentialOffer = createJSONCredentialOffer()
        jsonCredentialOffer["grants"] = []
        
        // Act / Assert
        XCTAssertThrowsError(try mapper.map(jsonCredentialOffer, type: CredentialOffer.self))
        { error in
            
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: "grants",
                                                                       in: "CredentialOffer"))
        }
    }
    
    private func createJSONCredentialOffer() -> [String: Any]
    {
        var json: [String: Any] = [
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
}
