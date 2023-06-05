/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PinRequirementTests: XCTestCase {
    
    func testValidate_WithoutPin_ThrowsError() async throws {
        
        // Arrange
        let pinRequirement = PinRequirement(required: false,
                                            length: 0,
                                            type: "",
                                            salt: nil)
        
        // Act
        XCTAssertThrowsError(try pinRequirement.validate().get()) { error in
            // Assert
            XCTAssert(error is RequirementNotMetError)
            XCTAssertNil((error as? RequirementNotMetError)?.correlationId)
            XCTAssertEqual((error as? RequirementNotMetError)?.code,
                           VerifiedIdErrors.ErrorCode.RequirementNotMet)
            XCTAssertEqual((error as? RequirementNotMetError)?.message, "Pin has not been set.")
        }
    }
    
    func testValidate_WithPin_DoesNotThrow() async throws {
        
        // Arrange
        let pinRequirement = PinRequirement(required: false,
                                            length: 0,
                                            type: "",
                                            salt: nil)
        pinRequirement.fulfill(with: "mock pin")
        
        // Act / Assert
        XCTAssertNoThrow(try pinRequirement.validate().get())
    }
    
    func testFulfill_WithPin_SetsAccessToken() async throws {
        
        // Arrange
        let pinRequirement = PinRequirement(required: false,
                                            length: 0,
                                            type: "",
                                            salt: nil)
        let mockPin = "mock pin"
        
        // Act
        pinRequirement.fulfill(with: mockPin)
        
        // Assert
        XCTAssertEqual(pinRequirement.pin, mockPin)
    }
}
