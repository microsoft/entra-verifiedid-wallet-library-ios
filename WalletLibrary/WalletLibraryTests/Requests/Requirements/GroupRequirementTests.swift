/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class GroupRequirementTests: XCTestCase {
    
    enum MockError: Error {
        case expectedInvalidRequirement
        case secondExpectedInvalidRequirement
        case thirdExpectedInvalidRequirement
    }
    
    func testValidate_WithOneInvalidRequirementInGroup_ThrowsError() async throws {
        
        // Arrange
        let requirement = MockRequirement(id: "", mockValidateCallback: { throw MockError.expectedInvalidRequirement })
        let groupRequirement = GroupRequirement(required: true,
                                                requirements: [requirement],
                                                requirementOperator: .ALL)
        
        // Act
        XCTAssertThrowsError(try groupRequirement.validate()) { error in
            // Assert
            XCTAssert(error is GroupRequirementError)
            
            switch (error as? GroupRequirementError) {
            case .requirementsAreNotValid(let errors):
                XCTAssertEqual(errors.count, 1)
                XCTAssertEqual(errors.first as? MockError, MockError.expectedInvalidRequirement)
            default:
                XCTFail("Error thrown was not group requirement error.")
            }
        }
    }
    
    func testValidate_WithMultipleInvalidRequirementInGroup_ThrowsError() async throws {
        
        // Arrange
        let firstRequirement = MockRequirement(id: "", mockValidateCallback: { throw MockError.expectedInvalidRequirement })
        let secondRequirement = MockRequirement(id: "", mockValidateCallback: { throw MockError.secondExpectedInvalidRequirement })
        let thirdRequirement = MockRequirement(id: "", mockValidateCallback: { throw MockError.thirdExpectedInvalidRequirement })
        let fourthRequirement = MockRequirement(id: "", mockValidateCallback: { throw MockError.expectedInvalidRequirement })

        let groupRequirement = GroupRequirement(required: true,
                                                requirements: [firstRequirement, secondRequirement, thirdRequirement, fourthRequirement],
                                                requirementOperator: .ALL)
        
        // Act
        XCTAssertThrowsError(try groupRequirement.validate()) { error in
            // Assert
            XCTAssert(error is GroupRequirementError)
            
            switch (error as? GroupRequirementError) {
            case .requirementsAreNotValid(let errors):
                XCTAssertEqual(errors.count, 4)
                XCTAssertEqual(errors.first as? MockError, MockError.expectedInvalidRequirement)
                XCTAssertEqual(errors[1] as? MockError, MockError.secondExpectedInvalidRequirement)
                XCTAssertEqual(errors[2] as? MockError, MockError.thirdExpectedInvalidRequirement)
                XCTAssertEqual(errors[3] as? MockError, MockError.expectedInvalidRequirement)

            default:
                XCTFail("Error thrown was not group requirement error.")
            }
        }
    }
    
    func testValidate_WithAllValidRequirementsInGroup_DoesNotThrow() async throws {
        // Arrange
        let firstRequirement = MockRequirement(id: "")
        let secondRequirement = MockRequirement(id: "")
        let thirdRequirement = MockRequirement(id: "")
        let fourthRequirement = MockRequirement(id: "")

        let groupRequirement = GroupRequirement(required: true,
                                                requirements: [firstRequirement, secondRequirement, thirdRequirement, fourthRequirement],
                                                requirementOperator: .ALL)
        
        // Act / Assert
        XCTAssertNoThrow(try groupRequirement.validate())
    }
}
