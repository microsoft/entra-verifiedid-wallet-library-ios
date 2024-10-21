/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class FormURLEncodedRequestEncoderTests: XCTestCase
{
    func testEncode_WithValidRequest_EncodesRequest() throws
    {
        // Arrange
        let encoder = FormURLEncodedRequestEncoder()
        let request = PreAuthTokenRequest(grant_type: "grant type",
                                          pre_authorized_code: "code",
                                          tx_code: "pin")
        
        // Act
        let encodedRequest = try encoder.encode(value: request)
        
        // Assert
        XCTAssertEqual(String(data: encodedRequest, encoding: .utf8),
                       try request.allProperties().toURLEncodedString())
    }
}
