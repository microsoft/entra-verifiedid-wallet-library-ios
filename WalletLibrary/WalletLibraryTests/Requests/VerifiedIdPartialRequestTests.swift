/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdPartialRequestTests: XCTestCase
{
    func testReplaceRequirement_WithRequirementNotMatching_ReturnsNil() async throws
    {
        var wasCalled = false
        
        let mockTransformer: ((VerifiedIdRequirement) -> Requirement) = { req in
            wasCalled = true
            return MockRequirement(id: "wrongId23")
        }
        
        // Arrange
        let mockReq = MockRequirement(id: "notMatchingId")
        let partialRequest = VerifiedIdPartialRequest(requesterStyle: MockRequesterStyle(requester: ""),
                                                      requirement: mockReq,
                                                      rootOfTrust: RootOfTrust(verified: false, source: nil))
        
        // Act / Assert
        XCTAssertNil(partialRequest.replaceRequirement(id: "mockId", how: mockTransformer))
        XCTAssertFalse(wasCalled)
    }
    
    func testReplaceRequirement_WithRequirementMatching_ReturnsUpdatedRequirement() async throws
    {
        let id = "expectedId"
        var wasCalled = false
        let expectedRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [],
                                                        id: id,
                                                        constraint: MockConstraint(doesMatchResult: true))
        
        let expectedResult = MockRequirement(id: id)
        
        let mockTransformer: ((VerifiedIdRequirement) -> Requirement) = { req in
            wasCalled = true
            return expectedResult
        }
        
        // Arrange
        let partialRequest = VerifiedIdPartialRequest(requesterStyle: MockRequesterStyle(requester: ""),
                                                      requirement: expectedRequirement,
                                                      rootOfTrust: RootOfTrust(verified: false, source: nil))
        
        // Act
        let result = partialRequest.replaceRequirement(id: id, how: mockTransformer)
        
        // Assert
        XCTAssert(wasCalled)
        XCTAssertEqual(partialRequest.requirement as? MockRequirement, expectedResult)
        print(partialRequest.requirement)
        XCTAssertEqual(result as? MockRequirement, expectedResult)
    }
    
    func testReplaceRequirement_WithGroupRequirement_ReturnsUpdatedRequirement() async throws
    {
        let id = "expectedId"
        var wasCalled = false
        let expectedRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [],
                                                        id: id,
                                                        constraint: MockConstraint(doesMatchResult: true))
        let mockRequirement1 = MockRequirement(id: "wrongId")
        let mockRequirement2 = MockRequirement(id: "wrongId2")
        
        let expectedResult = MockRequirement(id: id)
        
        let groupRequirement = GroupRequirement(required: true,
                                                requirements: [expectedRequirement, 
                                                               mockRequirement1,
                                                               mockRequirement2],
                                                requirementOperator: .ALL)
        
        let mockTransformer: ((VerifiedIdRequirement) -> Requirement) = { req in
            wasCalled = true
            return expectedResult
        }
        
        // Arrange
        let partialRequest = VerifiedIdPartialRequest(requesterStyle: MockRequesterStyle(requester: ""),
                                                      requirement: groupRequirement,
                                                      rootOfTrust: RootOfTrust(verified: false, source: nil))
        
        // Act
        let result = partialRequest.replaceRequirement(id: id, how: mockTransformer)
        
        // Assert
        XCTAssert(wasCalled)
        XCTAssertEqual((partialRequest.requirement as? GroupRequirement)?.requirements.count, 3)
        XCTAssertEqual((partialRequest.requirement as? GroupRequirement)?.requirements[0] as? MockRequirement,
                       expectedResult)
        XCTAssertEqual((partialRequest.requirement as? GroupRequirement)?.requirements[1] as? MockRequirement,
                       mockRequirement1)
        XCTAssertEqual((partialRequest.requirement as? GroupRequirement)?.requirements[2] as? MockRequirement,
                       mockRequirement2)
        XCTAssertEqual(result as? MockRequirement, expectedResult)
    }
    
    func testReplaceRequirement_WithGroupRequirementAndNoMatches_ReturnsNil() async throws
    {
        let id = "expectedId"
        var wasCalled = false
        let verifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [],
                                                        id: "wrongIdForVerifiedIdRequirement",
                                                        constraint: MockConstraint(doesMatchResult: true))
        let mockRequirement1 = MockRequirement(id: "wrongId")
        let mockRequirement2 = MockRequirement(id: "wrongId2")
        
        let expectedResult = MockRequirement(id: id)
        
        let groupRequirement = GroupRequirement(required: true,
                                                requirements: [verifiedIdRequirement,
                                                               mockRequirement1,
                                                               mockRequirement2],
                                                requirementOperator: .ALL)
        
        let mockTransformer: ((VerifiedIdRequirement) -> Requirement) = { req in
            wasCalled = true
            return expectedResult
        }
        
        // Arrange
        let partialRequest = VerifiedIdPartialRequest(requesterStyle: MockRequesterStyle(requester: ""),
                                                      requirement: groupRequirement,
                                                      rootOfTrust: RootOfTrust(verified: false, source: nil))
        
        // Act
        let result = partialRequest.replaceRequirement(id: id, how: mockTransformer)
        
        // Assert
        XCTAssertFalse(wasCalled)
        XCTAssertEqual((partialRequest.requirement as? GroupRequirement)?.requirements.count, 3)
        XCTAssertEqual(((partialRequest.requirement as? GroupRequirement)?.requirements[0] as? VerifiedIdRequirement)?.id,
                       verifiedIdRequirement.id)
        XCTAssertEqual((partialRequest.requirement as? GroupRequirement)?.requirements[1] as? MockRequirement,
                       mockRequirement1)
        XCTAssertEqual((partialRequest.requirement as? GroupRequirement)?.requirements[2] as? MockRequirement,
                       mockRequirement2)
        XCTAssertNil(result)
    }
    
    func testReplaceRequirement_With2GroupRequirements_ReturnsUpdatedRequirement() async throws
    {
        let id = "expectedId"
        var wasCalled = false
        let verifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [],
                                                        id: id,
                                                        constraint: MockConstraint(doesMatchResult: true))
        let mockRequirement1 = MockRequirement(id: "wrongId")
        let mockRequirement2 = MockRequirement(id: "wrongId2")
        
        let expectedResult = MockRequirement(id: id)
        
        let nestedRequirement = GroupRequirement(required: true,
                                                requirements: [verifiedIdRequirement,
                                                               mockRequirement1],
                                                requirementOperator: .ALL)
        
        let groupRequirement = GroupRequirement(required: true,
                                                requirements: [nestedRequirement,                                                                 mockRequirement2],
                                                requirementOperator: .ALL)
        
        let mockTransformer: ((VerifiedIdRequirement) -> Requirement) = { req in
            wasCalled = true
            return expectedResult
        }
        
        // Arrange
        let partialRequest = VerifiedIdPartialRequest(requesterStyle: MockRequesterStyle(requester: ""),
                                                      requirement: groupRequirement,
                                                      rootOfTrust: RootOfTrust(verified: false, source: nil))
        
        // Act
        let result = partialRequest.replaceRequirement(id: id, how: mockTransformer)
        
        // Assert
        XCTAssert(wasCalled)
        XCTAssertEqual((partialRequest.requirement as? GroupRequirement)?.requirements.count, 2)
        XCTAssertEqual((partialRequest.requirement as? GroupRequirement)?.requirements[1] as? MockRequirement,
                       mockRequirement2)
        XCTAssertEqual((partialRequest.requirement as? GroupRequirement)?.requirements.count, 2)
        let nestedRequirementResult = (partialRequest.requirement as? GroupRequirement)?.requirements[0] as? GroupRequirement
        XCTAssertEqual(nestedRequirementResult?.requirements.count, 2)
        XCTAssertEqual(nestedRequirementResult?.requirements[0] as? MockRequirement,
                       expectedResult)
        XCTAssertEqual(nestedRequirementResult?.requirements[1] as? MockRequirement,
                       mockRequirement1)
        XCTAssertEqual(result as? MockRequirement, expectedResult)
    }
    
    func testRemoveRequirement_WithMockRequirement_ReturnsFalse() async throws
    {
        let mockId = "mockId"
        let mockRequirement = MockRequirement(id: "mockId")
        
        // Arrange
        let partialRequest = VerifiedIdPartialRequest(requesterStyle: MockRequesterStyle(requester: ""),
                                                      requirement: mockRequirement,
                                                      rootOfTrust: RootOfTrust(verified: false, source: nil))
        
        // Act
        let result = partialRequest.removeRequirement(id: mockId)
        
        // Assert
        XCTAssertFalse(result)
    }
    
    func testRemoveRequirement_WithNoMatchingId_ReturnsFalse() async throws
    {
        let id = "expectedId"
        let mockRequirement1 = MockRequirement(id: "wrongId")
        let mockRequirement2 = MockRequirement(id: "wrongId2")
        
        let groupRequirement = GroupRequirement(required: true,
                                                requirements: [mockRequirement1, mockRequirement2],
                                                requirementOperator: .ALL)
        
        // Arrange
        let partialRequest = VerifiedIdPartialRequest(requesterStyle: MockRequesterStyle(requester: ""),
                                                      requirement: groupRequirement,
                                                      rootOfTrust: RootOfTrust(verified: false, source: nil))
        
        // Act
        let result = partialRequest.removeRequirement(id: id)
        
        // Assert
        XCTAssertFalse(result)
        XCTAssertEqual(groupRequirement.requirements.count, 2)
    }
    
    func testRemoveRequirement_WithMatchingId_ReturnsTrueAndRemovesReq() async throws
    {
        let id = "expectedId"
        let verifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [],
                                                        id: id,
                                                        constraint: MockConstraint(doesMatchResult: true))
        let mockRequirement2 = MockRequirement(id: "wrongId2")
        
        let groupRequirement = GroupRequirement(required: true,
                                                requirements: [verifiedIdRequirement,
                                                               mockRequirement2],
                                                requirementOperator: .ALL)
        
        // Arrange
        let partialRequest = VerifiedIdPartialRequest(requesterStyle: MockRequesterStyle(requester: ""),
                                                      requirement: groupRequirement,
                                                      rootOfTrust: RootOfTrust(verified: false, source: nil))
        
        // Act
        let result = partialRequest.removeRequirement(id: id)
        
        // Assert
        XCTAssert(result)
        XCTAssertEqual(groupRequirement.requirements.count, 1)
    }
}
