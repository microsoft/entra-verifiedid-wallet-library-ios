/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VCTypeConstraintTests: XCTestCase {
    
    let mockVerifiableCredentialHelper = MockVerifiableCredentialHelper()
    
    func testDoesMatch_WithUnsupportedVerifiedIdType_ReturnFalse() throws {
        // Arrange
        let constraint = VCTypeConstraint(type: "mockType")
        let unsupportedVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        
        // Act
        let result = constraint.doesMatch(verifiedId: unsupportedVerifiedId)
        
        // Assert
        XCTAssertFalse(result)
    }
    
    func testDoesMatch_WhenVCContainsType_ReturnTrue() throws {
        // Arrange
        let constraint = VCTypeConstraint(type: "mockType")
        let verifiableCredential = mockVerifiableCredentialHelper.createMockVerifiableCredential(expectedTypes: ["mockType"])
        
        // Act
        let result = constraint.doesMatch(verifiedId: verifiableCredential)
        
        // Assert
        XCTAssertTrue(result)
    }
    
    func testDoesMatch_WhenVCContainsMultipleTypes_ReturnTrue() throws {
        // Arrange
        let constraint = VCTypeConstraint(type: "mockType")
        let verifiableCredential = mockVerifiableCredentialHelper.createMockVerifiableCredential(expectedTypes: ["mockType", "unmatchingType"])
        
        // Act
        let result = constraint.doesMatch(verifiedId: verifiableCredential)
        
        // Assert
        XCTAssertTrue(result)
    }
    
    func testDoesMatch_WhenVCDoesNotContainType_ReturnFalse() throws {
        // Arrange
        let constraint = VCTypeConstraint(type: "mockType")
        let verifiableCredential = mockVerifiableCredentialHelper.createMockVerifiableCredential(expectedTypes: ["unmatchingType"])
        
        // Act
        let result = constraint.doesMatch(verifiedId: verifiableCredential)
        
        // Assert
        XCTAssertFalse(result)
    }
    
    func testMatches_WhenVCDoesNotContainType_ThrowsError() throws {
        // Arrange
        let constraint = VCTypeConstraint(type: "mockType")
        let verifiableCredential = mockVerifiableCredentialHelper.createMockVerifiableCredential(expectedTypes: ["unmatchingType"])
        
        // Act
        XCTAssertThrowsError(try constraint.matches(verifiedId: verifiableCredential)) { error in
            // Assert
            XCTAssert(error is VCTypeConstraintError)
            XCTAssertEqual(error as? VCTypeConstraintError, .verifiedIdDoesNotHaveSpecifiedType("mockType"))
        }
    }
    
    func testMatches_WhenVCDoesContainType_DoesNotThrow() throws {
        // Arrange
        let constraint = VCTypeConstraint(type: "mockType")
        let verifiableCredential = mockVerifiableCredentialHelper.createMockVerifiableCredential(expectedTypes: ["mockType"])
        
        // Act / Assert
        XCTAssertNoThrow(try constraint.matches(verifiedId: verifiableCredential))
    }
}
