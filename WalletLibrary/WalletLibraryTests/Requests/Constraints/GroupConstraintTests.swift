/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
import VCToken
@testable import WalletLibrary

class GroupConstraintTests: XCTestCase {
    
    func testDoesMatch_WithALLOperatorAndAllMatch_ReturnsTrue() throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let firstConstraint = MockConstraint(doesMatchResult: true)
        let secondConstraint = MockConstraint(doesMatchResult: true)
        let thirdConstraint = MockConstraint(doesMatchResult: true)
        let constraints = [firstConstraint, secondConstraint, thirdConstraint]
        let groupConstraint = GroupConstraint(constraints: constraints,
                                              constraintOperator: .ALL)
        
        // Act / Assert
        XCTAssert(groupConstraint.doesMatch(verifiedId: mockVerifiedId))
    }
    
    func testDoesMatch_WithALLOperatorAndOneDoesNotMatch_ReturnsFalse() throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let firstConstraint = MockConstraint(doesMatchResult: true)
        let secondConstraint = MockConstraint(doesMatchResult: false)
        let thirdConstraint = MockConstraint(doesMatchResult: true)
        let constraints = [firstConstraint, secondConstraint, thirdConstraint]
        let groupConstraint = GroupConstraint(constraints: constraints,
                                              constraintOperator: .ALL)
        
        // Act / Assert
        XCTAssertFalse(groupConstraint.doesMatch(verifiedId: mockVerifiedId))
    }
    
    func testDoesMatch_WithANYOperatorAndOneMatches_ReturnsTrue() throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let firstConstraint = MockConstraint(doesMatchResult: false)
        let secondConstraint = MockConstraint(doesMatchResult: false)
        let thirdConstraint = MockConstraint(doesMatchResult: true)
        let constraints = [firstConstraint, secondConstraint, thirdConstraint]
        let groupConstraint = GroupConstraint(constraints: constraints,
                                              constraintOperator: .ANY)
        
        // Act / Assert
        XCTAssert(groupConstraint.doesMatch(verifiedId: mockVerifiedId))
    }
    
    func testDoesMatch_WithANYOperatorAndNoneMatch_ReturnsFalse() throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let firstConstraint = MockConstraint(doesMatchResult: false)
        let secondConstraint = MockConstraint(doesMatchResult: false)
        let thirdConstraint = MockConstraint(doesMatchResult: false)
        let constraints = [firstConstraint, secondConstraint, thirdConstraint]
        let groupConstraint = GroupConstraint(constraints: constraints,
                                              constraintOperator: .ANY)
        
        // Act / Assert
        XCTAssertFalse(groupConstraint.doesMatch(verifiedId: mockVerifiedId))
    }
    
    func testMatches_WithALLOperatorAndAllMatch_DoesNotThrow() throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let firstConstraint = MockConstraint(doesMatchResult: true)
        let secondConstraint = MockConstraint(doesMatchResult: true)
        let thirdConstraint = MockConstraint(doesMatchResult: true)
        let constraints = [firstConstraint, secondConstraint, thirdConstraint]
        let groupConstraint = GroupConstraint(constraints: constraints,
                                              constraintOperator: .ALL)
        
        // Act / Assert
        XCTAssertNoThrow(try groupConstraint.matches(verifiedId: mockVerifiedId))
    }
    
    func testMatches_WithALLOperatorAndOneDoesNotMatch_ThrowsError() throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let firstConstraint = MockConstraint(doesMatchResult: true)
        let secondConstraint = MockConstraint(doesMatchResult: false)
        let thirdConstraint = MockConstraint(doesMatchResult: true)
        let constraints = [firstConstraint, secondConstraint, thirdConstraint]
        let groupConstraint = GroupConstraint(constraints: constraints,
                                              constraintOperator: .ALL)
        
        // Act
        XCTAssertThrowsError(try groupConstraint.matches(verifiedId: mockVerifiedId)) { error in
            // Assert
            XCTAssert(error is GroupConstraintError)
            switch (error as? GroupConstraintError) {
            case .atleastOneConstraintDoesNotMatch(errors: let errors):
                for err in errors {
                    XCTAssertEqual(err as? MockConstraint.MockConstraintError, .expectedToThrow)
                }
            default:
                XCTFail()
            }
        }
    }
    
    func testMatches_WithANYOperatorAndOneMatches_DoesNotThrow() throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let firstConstraint = MockConstraint(doesMatchResult: false)
        let secondConstraint = MockConstraint(doesMatchResult: false)
        let thirdConstraint = MockConstraint(doesMatchResult: true)
        let constraints = [firstConstraint, secondConstraint, thirdConstraint]
        let groupConstraint = GroupConstraint(constraints: constraints,
                                              constraintOperator: .ANY)
        
        // Act / Assert
        XCTAssertNoThrow(try groupConstraint.matches(verifiedId: mockVerifiedId))
    }
    
    func testMatches_WithANYOperatorAndNoneMatch_ThrowsError() throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let firstConstraint = MockConstraint(doesMatchResult: false)
        let secondConstraint = MockConstraint(doesMatchResult: false)
        let thirdConstraint = MockConstraint(doesMatchResult: false)
        let constraints = [firstConstraint, secondConstraint, thirdConstraint]
        let groupConstraint = GroupConstraint(constraints: constraints,
                                              constraintOperator: .ANY)
        
        // Act
        XCTAssertThrowsError(try groupConstraint.matches(verifiedId: mockVerifiedId)) { error in
            // Assert
            XCTAssert(error is GroupConstraintError)
            switch (error as? GroupConstraintError) {
            case .noConstraintsMatch(errors: let errors):
                for err in errors {
                    XCTAssertEqual(err as? MockConstraint.MockConstraintError, .expectedToThrow)
                }
            default:
                XCTFail()
            }
        }
    }
}
