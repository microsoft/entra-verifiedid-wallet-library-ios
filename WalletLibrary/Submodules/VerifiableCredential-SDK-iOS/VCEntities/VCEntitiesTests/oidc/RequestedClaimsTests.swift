/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class RequestedClaimsTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    func testEncode_WithOneVp_DecodesValue() throws {
        // Arrange
        let mockData =
        """
        {
            "vp_token": {
                "presentation_definition": {
                    "id": "test"
                }
            }
        }
        """
        let encodedValue = mockData.data(using: .utf8)!
        
        // Act
        let requestedClaims = try decoder.decode(RequestedClaims.self, from: encodedValue)
        
        // Assert
        XCTAssertEqual(requestedClaims.vpToken.count, 1)
        XCTAssertEqual(requestedClaims.vpToken.first?.presentationDefinition?.id, "test")
    }
    
    func testEncode_WithThreeVps_DecodesValue() throws {
        // Arrange
        let mockData =
        """
        {
            "vp_token": [
                {
                "presentation_definition": {
                    "id": "test"
                    }
                },
                {
                "presentation_definition": {
                    "id": "test2"
                    }
                }
            ]
        }
        """
        let encodedValue = mockData.data(using: .utf8)!
        
        // Act
        let requestedClaims = try decoder.decode(RequestedClaims.self, from: encodedValue)
        
        // Assert
        XCTAssertEqual(requestedClaims.vpToken.count, 2)
        XCTAssertEqual(requestedClaims.vpToken.first?.presentationDefinition?.id, "test")
        XCTAssertEqual(requestedClaims.vpToken[1].presentationDefinition?.id, "test2")
    }
}
