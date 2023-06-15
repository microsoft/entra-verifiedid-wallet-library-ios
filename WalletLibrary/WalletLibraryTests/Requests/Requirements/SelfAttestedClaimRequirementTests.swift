/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class SelfAttestedClaimRequirementTests: XCTestCase {
    
    func testValidate_WithoutValue_ThrowsError() async throws {
        
        // Arrange
        let requirement = SelfAttestedClaimRequirement(encrypted: false,
                                                       required: true,
                                                       claim: "")
        
        // Act
        XCTAssertThrowsError(try requirement.validate().get()) { error in
            // Assert
            XCTAssert(error is RequirementNotMetError)
            XCTAssertEqual((error as? RequirementNotMetError)?.code, VerifiedIdErrors.ErrorCode.RequirementNotMet)
            XCTAssertEqual((error as? RequirementNotMetError)?.message, "Self Attested Claim has not been set.")
            XCTAssertNil((error as! RequirementNotMetError).errors)
        }
    }
    
    func testValidate_WithValue_DoesNotThrow() async throws {
        
        // Arrange
        let requirement = SelfAttestedClaimRequirement(encrypted: false,
                                                       required: true,
                                                       claim: "")
        requirement.fulfill(with: "mock value")
        
        // Act / Assert
        XCTAssertNoThrow(try requirement.validate().get())
    }
    
    func testFulfill_WithValue_SetsSelfAttestedClaimRequirement() async throws {
        
        // Arrange
        let requirement = SelfAttestedClaimRequirement(encrypted: false,
                                                       required: true,
                                                       claim: "")
        let mockValue = "mock value"
        
        // Act
        requirement.fulfill(with: mockValue)
        
        // Assert
        XCTAssertEqual(requirement.value, mockValue)
    }
}
