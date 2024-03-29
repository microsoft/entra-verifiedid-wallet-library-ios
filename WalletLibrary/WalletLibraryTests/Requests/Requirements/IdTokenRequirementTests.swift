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
                                                    scope: "")
        
        // Act
        XCTAssertThrowsError(try idTokenRequirement.validate().get()) { error in
            // Assert
            XCTAssert(error is RequirementNotMetError)
            XCTAssertEqual((error as? RequirementNotMetError)?.code, VerifiedIdErrors.ErrorCode.RequirementNotMet)
            XCTAssertEqual((error as? RequirementNotMetError)?.message, "Id Token has not been set.")
            XCTAssertNil((error as! RequirementNotMetError).errors)
        }
    }
    
    func testValidate_WithIdToken_DoesNotThrow() async throws {
        
        // Arrange
        let idTokenRequirement = IdTokenRequirement(encrypted: false,
                                                    required: true,
                                                    configuration: URL(string: "https://test.com")!,
                                                    clientId: "",
                                                    redirectUri: "",
                                                    scope: "")
        idTokenRequirement.fulfill(with: "mock token")
        
        // Act / Assert
        XCTAssertNoThrow(try idTokenRequirement.validate().get())
    }
    
    func testFulfill_WithIdToken_SetsAccessToken() async throws {
        
        // Arrange
        let idTokenRequirement = IdTokenRequirement(encrypted: false,
                                                    required: true,
                                                    configuration: URL(string: "https://test.com")!,
                                                    clientId: "",
                                                    redirectUri: "",
                                                    scope: "")
        let mockToken = "mock token"
        
        // Act
        idTokenRequirement.fulfill(with: mockToken)
        
        // Assert
        XCTAssertEqual(idTokenRequirement.idToken, mockToken)
    }
}
