/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdRequirementTests: XCTestCase {

    func testValidate_WithNoSelectedVerifiedId_ThrowsError() async throws {
        // Arrange
        let mockConstraint = MockConstraint(doesMatchResult: false)
        let requirement = VerifiedIdRequirement(encrypted: false,
                                                required: false,
                                                types: ["mockType"],
                                                purpose: nil,
                                                issuanceOptions: [],
                                                id: nil,
                                                constraint: mockConstraint)
        
        // Act
        XCTAssertThrowsError(try requirement.validate().get()) { error in
            // Assert
            XCTAssert(error is VerifiedIdRequirementError)
            XCTAssertEqual(error as? VerifiedIdRequirementError, .requirementHasNotBeenFulfilled)
        }
    }
    
    func testValidate_WhenConstraintsDoNotMatch_ThrowsError() async throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let mockConstraint = MockConstraint(doesMatchResult: false)
        
        let requirement = VerifiedIdRequirement(encrypted: false,
                                                required: false,
                                                types: ["mockType"],
                                                purpose: nil,
                                                issuanceOptions: [],
                                                id: nil,
                                                constraint: mockConstraint)
        requirement.selectedVerifiedId = mockVerifiedId
        
        // Act
        XCTAssertThrowsError(try requirement.validate().get()) { error in
            // Assert
            XCTAssert(error is VerifiedIdRequirementError)
            XCTAssertEqual(error as? VerifiedIdRequirementError, .verifiedIdDoesNotMeetConstraints)
        }
    }
    
    func testValidate_ForValidInput_DoesNotThrowError() async throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let mockConstraint = MockConstraint(doesMatchResult: true)
        
        let requirement = VerifiedIdRequirement(encrypted: false,
                                                required: false,
                                                types: ["mockType"],
                                                purpose: nil,
                                                issuanceOptions: [],
                                                id: nil,
                                                constraint: mockConstraint)
        requirement.selectedVerifiedId = mockVerifiedId
        
        // Act
        XCTAssertNoThrow(try requirement.validate().get())
    }
    
    func testGetMatches_WhenConstraintsDoNotMatchAnyVerifiedIds_ReturnsEmptyList() async throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let mockConstraint = MockConstraint(doesMatchResult: false)
        
        let requirement = VerifiedIdRequirement(encrypted: false,
                                                required: false,
                                                types: ["mockType"],
                                                purpose: nil,
                                                issuanceOptions: [],
                                                id: nil,
                                                constraint: mockConstraint)
        
        // Act
        let result = requirement.getMatches(verifiedIds: [mockVerifiedId])
        
        // Assert
        XCTAssert(result.isEmpty)
    }
    
    func testGetMatches_WhenConstraintsDoMatchOneVerifiedId_ReturnsVerifiedIdInList() async throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let mockConstraint = MockConstraint(doesMatchResult: true)
        
        let requirement = VerifiedIdRequirement(encrypted: false,
                                                required: false,
                                                types: ["mockType"],
                                                purpose: nil,
                                                issuanceOptions: [],
                                                id: nil,
                                                constraint: mockConstraint)
        
        // Act
        let result = requirement.getMatches(verifiedIds: [mockVerifiedId])
        
        // Assert
        XCTAssertEqual(result.first as? MockVerifiedId, mockVerifiedId)
    }
    
    func testGetMatches_WhenConstraintsDoMatchTwoVerifiedIds_ReturnsVerifiedIdsInList() async throws {
        // Arrange
        let mockVerifiedId1 = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let mockVerifiedId2 = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let mockConstraint = MockConstraint(doesMatchResult: true)
        
        let requirement = VerifiedIdRequirement(encrypted: false,
                                                required: false,
                                                types: ["mockType"],
                                                purpose: nil,
                                                issuanceOptions: [],
                                                id: nil,
                                                constraint: mockConstraint)
        
        // Act
        let result = requirement.getMatches(verifiedIds: [mockVerifiedId1, mockVerifiedId2])
        
        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first as? MockVerifiedId, mockVerifiedId1)
        XCTAssertEqual(result[1] as? MockVerifiedId, mockVerifiedId2)
    }
    
    func testFulfill_WhenConstraintsDoNotMatchVerifiedId_ThrowsError() async throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let mockConstraint = MockConstraint(doesMatchResult: false)
        
        let requirement = VerifiedIdRequirement(encrypted: false,
                                                required: false,
                                                types: ["mockType"],
                                                purpose: nil,
                                                issuanceOptions: [],
                                                id: nil,
                                                constraint: mockConstraint)
        
        // Act
        XCTAssertThrowsError(try requirement.fulfill(with: mockVerifiedId).get()) { error in
            // Assert
            XCTAssert(error is VerifiedIdRequirementError)
            XCTAssertEqual(error as? VerifiedIdRequirementError, .verifiedIdDoesNotMeetConstraints)
        }
    }
    
    func testFulfill_WhenConstraintsDoMatchVerifiedId_SelectedVerifiedIdFulfilled() async throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let mockConstraint = MockConstraint(doesMatchResult: true)
        
        let requirement = VerifiedIdRequirement(encrypted: false,
                                                required: false,
                                                types: ["mockType"],
                                                purpose: nil,
                                                issuanceOptions: [],
                                                id: nil,
                                                constraint: mockConstraint)
        
        // Act / Assert
        XCTAssertNoThrow(try requirement.fulfill(with: mockVerifiedId).get())
        XCTAssertEqual(requirement.selectedVerifiedId as? MockVerifiedId, mockVerifiedId)
    }
}
