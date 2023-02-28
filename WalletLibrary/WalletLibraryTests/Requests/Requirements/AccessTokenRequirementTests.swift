/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class AccessTokenRequirementTests: XCTestCase {
    
    func testValidate_WithoutAccessToken_ThrowsError() async throws {
        
        // Arrange
        let accessTokenRequirement = AccessTokenRequirement(encrypted: false,
                                                            required: false,
                                                            configuration: "",
                                                            clientId: nil,
                                                            resourceId: "",
                                                            scope: "")
        
        // Act
        XCTAssertThrowsError(try accessTokenRequirement.validate()) { error in
            // Assert
            XCTAssert(error is AccessTokenRequirementError)
            XCTAssertEqual(error as? AccessTokenRequirementError, .accessTokenRequirementHasNotBeenFulfilled)
        }
    }
    
    func testValidate_WithAccessToken_DoesNotThrow() async throws {
        
        // Arrange
        let accessTokenRequirement = AccessTokenRequirement(encrypted: false,
                                                            required: false,
                                                            configuration: "",
                                                            clientId: nil,
                                                            resourceId: "",
                                                            scope: "")
        accessTokenRequirement.fulfill(with: "mock token")
        
        // Act / Assert
        XCTAssertNoThrow(try accessTokenRequirement.validate())
    }
    
    func testFulfill_WithAccessToken_SetsAccessToken() async throws {
        
        // Arrange
        let accessTokenRequirement = AccessTokenRequirement(encrypted: false,
                                                            required: false,
                                                            configuration: "",
                                                            clientId: nil,
                                                            resourceId: "",
                                                            scope: "")
        let mockToken = "mock token"
        
        // Act
        accessTokenRequirement.fulfill(with: mockToken)
        
        // Assert
        XCTAssertEqual(accessTokenRequirement.accessToken, mockToken)
    }
}
