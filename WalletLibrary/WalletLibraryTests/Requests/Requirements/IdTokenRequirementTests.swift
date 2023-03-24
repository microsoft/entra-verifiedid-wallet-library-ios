/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class IdTokenRequirementTests: XCTestCase {
    
    func testValidate_WithoutIdToken_ThrowsError() async throws {
        
        // Arrange
        let idTokenRequirement = IdTokenRequirement(encrypted: false,
                                                    required: true,
                                                    configuration: URL(string: "https://test.com")!,
                                                    clientId: "",
                                                    redirectUri: "",
                                                    scope: "",
                                                    nonce: nil)
        
        // Act
        XCTAssertThrowsError(try idTokenRequirement.validate()) { error in
            // Assert
            XCTAssert(error is IdTokenRequirementError)
            XCTAssertEqual(error as? IdTokenRequirementError, .idTokenRequirementHasNotBeenFulfilled)
        }
    }
    
    func testValidate_WithIdToken_DoesNotThrow() async throws {
        
        // Arrange
        let idTokenRequirement = IdTokenRequirement(encrypted: false,
                                                    required: true,
                                                    configuration: URL(string: "https://test.com")!,
                                                    clientId: "",
                                                    redirectUri: "",
                                                    scope: "",
                                                    nonce: nil)
        idTokenRequirement.fulfill(with: "mock token")
        
        // Act / Assert
        XCTAssertNoThrow(try idTokenRequirement.validate())
    }
    
    func testFulfill_WithIdToken_SetsAccessToken() async throws {
        
        // Arrange
        let idTokenRequirement = IdTokenRequirement(encrypted: false,
                                                    required: true,
                                                    configuration: URL(string: "https://test.com")!,
                                                    clientId: "",
                                                    redirectUri: "",
                                                    scope: "",
                                                    nonce: nil)
        let mockToken = "mock token"
        
        // Act
        idTokenRequirement.fulfill(with: mockToken)
        
        // Assert
        XCTAssertEqual(idTokenRequirement.idToken, mockToken)
    }
}
