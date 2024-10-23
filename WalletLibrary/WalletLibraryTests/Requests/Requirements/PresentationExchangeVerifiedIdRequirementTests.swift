/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationExchangeVerifiedIdRequirementTests: XCTestCase {
    
    func testValidate_WithNoSelectedVerifiedId_ThrowsError() async throws {
        // Arrange
        let expectedInputDescriptor = "test-input-id"
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let mockConstraint = MockConstraint(doesMatchResult: true)
        let requirement = PresentationExchangeVerifiedIdRequirement(encrypted: false,
                                                required: false,
                                                types: ["mockType"],
                                                purpose: nil,
                                                issuanceOptions: [],
                                                id: nil,
                                                constraint: mockConstraint,
                                                inputDescriptorId: expectedInputDescriptor,
                                                format: "jwt_vc",
                                                exclusivePresentationWith: nil)
        
        
        // Act
        XCTAssertThrowsError(try requirement.validate().get()) { error in
            // Assert
            XCTAssert(error is RequirementNotMetError)
            XCTAssertEqual((error as? RequirementNotMetError)?.code, VerifiedIdErrors.ErrorCode.RequirementNotMet)
            XCTAssertEqual((error as? RequirementNotMetError)?.message, "Verified Id has not been set.")
            XCTAssertNil((error as! RequirementNotMetError).errors)
        }
    }
    
}
