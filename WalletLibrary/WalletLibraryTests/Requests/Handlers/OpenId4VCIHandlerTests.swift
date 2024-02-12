/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenId4VCIHandlerTests: XCTestCase 
{
    func testCanHandle_WithInvalidRawRequest_ReturnsFalse() async throws
    {
        // Arrange
        let invalidRawRequest = "invalid raw request"
        let configuration = LibraryConfiguration()
        let handler = OpenId4VCIHandler(configuration: configuration)
        
        // Act / Assert
        XCTAssertFalse(handler.canHandle(rawRequest: invalidRawRequest))
    }
    
    func testCanHandle_WithInvalidJSONRequest_ReturnsFalse() async throws
    {
        // Arrange
        let invalidRawRequest = ["invalid": "request"]
        let configuration = LibraryConfiguration()
        let handler = OpenId4VCIHandler(configuration: configuration)
        
        // Act / Assert
        XCTAssertFalse(handler.canHandle(rawRequest: invalidRawRequest))
    }
    
    func testCanHandle_WithValidJSONRequest_ReturnsTrue() async throws
    {
        // Arrange
        let rawRequest = createJSONCredentialOffer()
        let configuration = LibraryConfiguration()
        let handler = OpenId4VCIHandler(configuration: configuration)
        
        // Act / Assert
        XCTAssert(handler.canHandle(rawRequest: rawRequest))
    }
    
    func testHandle_WithInvalidRawRequest_ThrowsError() async throws 
    {
        // Arrange
        let invalidRawRequest = "invalid raw request"
        let configuration = LibraryConfiguration()
        let handler = OpenId4VCIHandler(configuration: configuration)
        
        do
        {
            // Act
            let _ = try await handler.handle(rawRequest: invalidRawRequest)
        }
        catch
        {
            // Assert
            XCTAssert(error is OpenId4VCIValidationError)
//            XCTAssertEqual(error as? OpenId4VCIProtocolValidationError, .InputNotSupported)
        }
    }
    
    func testHandle_WithRawRequest_ReturnsVerifiedIdRequest() async throws
    {
        // TODO: handle successful case in next PR
    }
    
    private func createJSONCredentialOffer() -> [String: Any]
    {
        var json: [String: Any] = [
            "credential_issuer": "expectedCredentialIssuer",
            "issuer_session": "expectedIssuerSession",
            "credential_configuration_ids": ["expectedCredentialIds"],
            "grants": [
                "authorization_code": [
                    "authorization_server": "expectedAuthorizationServer"
                ]
            ]
        ]
        
        return json
    }
}
