/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
import VCToken
@testable import WalletLibrary

class VerifiedIdGroupConstraintTests: XCTestCase {
    
    func testDoesMatch_WithALLOperatorAndAllMatch_ReturnsTrue() throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        let firstConstraint = MockConstraint(doesMatchResult: true)
        let secondConstraint = MockConstraint(doesMatchResult: true)
        let thirdConstraint = MockConstraint(doesMatchResult: true)
        let constraints = [firstConstraint, secondConstraint, thirdConstraint]
        let groupConstraint = VerifiedIdGroupConstraint(constraints: constraints,
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
        let groupConstraint = VerifiedIdGroupConstraint(constraints: constraints,
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
        let groupConstraint = VerifiedIdGroupConstraint(constraints: constraints,
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
        let groupConstraint = VerifiedIdGroupConstraint(constraints: constraints,
                                                        constraintOperator: .ANY)
        
        // Act / Assert
        XCTAssertFalse(groupConstraint.doesMatch(verifiedId: mockVerifiedId))
    }
}
