/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationExchangeFieldConstraintTests: XCTestCase {
    
    let mockVerifiableCredentialHelper = MockVerifiableCredentialHelper()
    
    func testInit_WithNoPathsOnField_ThrowsError() throws {
        // Arrange
        let field = PresentationExchangeField(path: nil,
                                              purpose: nil,
                                              filter: nil)

        // Act
        XCTAssertThrowsError(try PresentationExchangeFieldConstraint(field: field)) { error in
            // Assert
            XCTAssert(error is PresentationExchangeFieldConstraintError)
            XCTAssertEqual(error as? PresentationExchangeFieldConstraintError,
                           .NoPathsFoundOnPresentationExchangeField)
        }
    }
    
    func testInit_WithEmptyPathsOnField_ThrowsError() throws {
        // Arrange
        let mockFilter = PresentationExchangeFilter(pattern: try NSRegularExpression(pattern: "test"))
        let field = PresentationExchangeField(path: [],
                                              purpose: nil,
                                              filter: mockFilter)

        // Act
        XCTAssertThrowsError(try PresentationExchangeFieldConstraint(field: field)) { error in
            // Assert
            XCTAssert(error is PresentationExchangeFieldConstraintError)
            XCTAssertEqual(error as? PresentationExchangeFieldConstraintError,
                           .NoPathsFoundOnPresentationExchangeField)
        }
    }
    
    func testInit_WithInvalidPatternOnFilter_ThrowsError() throws {
        // Arrange
        let field = PresentationExchangeField(path: ["mock path"],
                                              purpose: nil,
                                              filter: nil)

        // Act
        XCTAssertThrowsError(try PresentationExchangeFieldConstraint(field: field)) { error in
            // Assert
            XCTAssert(error is PresentationExchangeFieldConstraintError)
            XCTAssertEqual(error as? PresentationExchangeFieldConstraintError,
                           .InvalidPatternOnThePresentationExchangeField)
        }
    }
    
    func testMapping_WithEmptyPathsOnField_ThrowsError() throws {
        // Arrange
        let field = PresentationExchangeField(path: [],
                                              purpose: nil,
                                              filter: nil)

        // Act
        XCTAssertThrowsError(try field.map(using: Mapper())) { error in
            // Assert
            XCTAssert(error is PresentationExchangeFieldConstraintError)
            XCTAssertEqual(error as? PresentationExchangeFieldConstraintError,
                           .NoPathsFoundOnPresentationExchangeField)
        }
    }
    
    func testInit_WithPathsOnField_DoesNotThrow() throws {
        // Arrange
        let mockPath = "mock path"
        let mockFilter = PresentationExchangeFilter(pattern: try NSRegularExpression(pattern: "test"))
        
        let field = PresentationExchangeField(path: [mockPath],
                                              purpose: nil,
                                              filter: mockFilter)

        // Act
        XCTAssertNoThrow(try PresentationExchangeFieldConstraint(field: field))
    }
    
    func testMatches_WithInvalidVerifiedIdType_ThrowsError() throws {
        // Arrange
        let mockPath = "mock path"
        let invalidTypeVerifiedId = MockVerifiedId(id: "id",
                                                   issuedOn: Date())
        let mockFilter = PresentationExchangeFilter(pattern: try NSRegularExpression(pattern: "test"))
        let field = PresentationExchangeField(path: [mockPath],
                                              purpose: nil,
                                              filter: mockFilter)
        let constraint = try PresentationExchangeFieldConstraint(field: field)

        // Act
        XCTAssertThrowsError(try constraint.matches(verifiedId: invalidTypeVerifiedId)) { error in
            // Assert
            XCTAssert(error is PresentationExchangeFieldConstraintError)
            XCTAssertEqual(error as? PresentationExchangeFieldConstraintError,
                           .UnableToCastVerifiedIdToVerifiableCredential)
        }
    }
    
    func testMatches_WithNoMatches_ThrowsError() throws {
        // Arrange
        let mockPath = "mock path"
        let mockFilter = PresentationExchangeFilter(pattern: try NSRegularExpression(pattern: "test"))
        let verifiableCredential = mockVerifiableCredentialHelper.createMockVerifiableCredential(claims: ["key": "mock value"])
        let field = PresentationExchangeField(path: [mockPath],
                                              purpose: nil,
                                              filter: mockFilter)
        let constraint = try PresentationExchangeFieldConstraint(field: field)

        // Act
        XCTAssertThrowsError(try constraint.matches(verifiedId: verifiableCredential)) { error in
            // Assert
            XCTAssert(error is PresentationExchangeFieldConstraintError)
            XCTAssertEqual(error as? PresentationExchangeFieldConstraintError,
                           .VerifiedIdDoesNotMatchConstraints)
        }
    }
    
    func testMatches_WithAClaimMatch_DoesNotThrowError() throws {
        // Arrange
        let mockPath = "$.vc.credentialSubject.email"
        let expectedValue = "expected value"
        let filter = PresentationExchangeFilter(type: "string", pattern: try NSRegularExpression(pattern: expectedValue))
        let verifiableCredential = mockVerifiableCredentialHelper.createMockVerifiableCredential(claims: ["email": expectedValue])
        let field = PresentationExchangeField(path: [mockPath],
                                              purpose: nil,
                                              filter: filter)
        let constraint = try PresentationExchangeFieldConstraint(field: field)

        // Act
        XCTAssertNoThrow(try constraint.matches(verifiedId: verifiableCredential))
    }
    
    func testMatches_WithAnIssuerMatch_DoesNotThrowError() throws {
        // Arrange
        let expectedValue = "expected issuer"
        let filter = PresentationExchangeFilter(type: "string", pattern: try NSRegularExpression(pattern: expectedValue))
        let verifiableCredential = mockVerifiableCredentialHelper.createMockVerifiableCredential(issuer: expectedValue)
        let field = PresentationExchangeField(path: ["$.issuer", "$.vc.issuer", "$.iss"],
                                              purpose: nil,
                                              filter: filter)
        let constraint = try PresentationExchangeFieldConstraint(field: field)

        // Act
        XCTAssertNoThrow(try constraint.matches(verifiedId: verifiableCredential))
    }
    
    func testDoesMatch_WithNoMatches_ReturnsFalse() throws {
        // Arrange
        let mockPath = "mock path"
        let mockFilter = PresentationExchangeFilter(pattern: try NSRegularExpression(pattern: "test"))
        let verifiableCredential = mockVerifiableCredentialHelper.createMockVerifiableCredential(claims: ["key": "mock value"])
        let field = PresentationExchangeField(path: [mockPath],
                                              purpose: nil,
                                              filter: mockFilter)
        let constraint = try PresentationExchangeFieldConstraint(field: field)

        // Act / Assert
        XCTAssertFalse(constraint.doesMatch(verifiedId: verifiableCredential))
    }
    
    func testDoesMatch_WithAClaimMatch_ReturnsTrue() throws {
        // Arrange
        let mockPath = "$.vc.credentialSubject.email"
        let expectedValue = "expected value"
        let filter = PresentationExchangeFilter(type: "string", pattern: try NSRegularExpression(pattern: expectedValue))
        let verifiableCredential = mockVerifiableCredentialHelper.createMockVerifiableCredential(claims: ["email": expectedValue])
        let field = PresentationExchangeField(path: [mockPath],
                                              purpose: nil,
                                              filter: filter)
        let constraint = try PresentationExchangeFieldConstraint(field: field)

        // Act
        XCTAssert(constraint.doesMatch(verifiedId: verifiableCredential))
    }
    
    func testDoesMatch_WithAnIssuerMatch_ReturnsTrue() throws {
        // Arrange
        let expectedValue = "expected issuer"
        let filter = PresentationExchangeFilter(type: "string", pattern: try NSRegularExpression(pattern: expectedValue))
        let verifiableCredential = mockVerifiableCredentialHelper.createMockVerifiableCredential(issuer: expectedValue)
        let field = PresentationExchangeField(path: ["$.issuer", "$.vc.issuer", "$.iss"],
                                              purpose: nil,
                                              filter: filter)
        let constraint = try PresentationExchangeFieldConstraint(field: field)

        // Act
        XCTAssert(constraint.doesMatch(verifiedId: verifiableCredential))
    }
}
