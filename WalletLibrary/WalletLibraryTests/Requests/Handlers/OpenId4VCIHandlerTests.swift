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
        
        // Act
        XCTAssertFalse(handler.canHandle(rawRequest: invalidRawRequest))
    }
    
    func testCanHandle_WithInvalidJSONRequest_ReturnsFalse() async throws
    {
        
        // Arrange
        let invalidRawRequest = ["invalid": "request"]
        let configuration = LibraryConfiguration()
        let handler = OpenId4VCIHandler(configuration: configuration)
        
        // Act
        XCTAssertFalse(handler.canHandle(rawRequest: invalidRawRequest))
    }
    
    func testCanHandle_WithValidJSONRequest_ReturnsTrue() async throws
    {
        
        // Arrange
        let invalidRawRequest = ["credential_issuer": "mock value"]
        let configuration = LibraryConfiguration()
        let handler = OpenId4VCIHandler(configuration: configuration)
        
        // Act
        XCTAssert(handler.canHandle(rawRequest: invalidRawRequest))
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
            XCTAssert(error is OpenId4VCIHandlerError)
            XCTAssertEqual(error as? OpenId4VCIHandlerError, .InputNotSupported)
        }
    }
    
    func testHandle_WithRawRequest_ReturnsVerifiedIdRequest() async throws
    {
        // TODO: handle successful case in next PR
    }
}
