/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class ContractIssuanceRequestTests: XCTestCase {
    
    enum ExpectedError: Error, Equatable {
        case expectedToBeThrown
    }
    
    func testIsSatisfied_WithInvalidRequirement_ReturnsFalse() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let mockMapper = MockMapper()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let mockVCRequester = MockVerifiedIdRequester()
        let mockIssuanceResponseContainer = MockIssuanceResponseContainer()
        
        let mockRequirement = MockRequirement(id: "mockRequirement324",
                                              mockValidateCallback: { throw ExpectedError.expectedToBeThrown })
        
        let content = IssuanceRequestContent(style: mockStyle,
                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                             requirement: mockRequirement,
                                             rootOfTrust: mockRootOfTrust)
        
        let contractIssuanceRequest = ContractIssuanceRequest(content: content,
                                                              issuanceResponseContainer: mockIssuanceResponseContainer,
                                                              verifiedIdRequester: mockVCRequester,
                                                              configuration: configuration)
        
        // Act
        let actualResult = contractIssuanceRequest.isSatisfied()
        
        // Assert
        XCTAssertFalse(actualResult)
    }
    
    func testIsSatisfied_WithOneInvalidRequirementofMultipleValidRequirements_ReturnsFalse() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let mockMapper = MockMapper()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let mockVCRequester = MockVerifiedIdRequester()
        let mockIssuanceResponseContainer = MockIssuanceResponseContainer()
        
        let invalidRequirement = MockRequirement(id: "mockRequirement324",
                                              mockValidateCallback: { throw ExpectedError.expectedToBeThrown })
        let firstValidRequirement = MockRequirement(id: "mockRequirement634")
        let secondValidRequirement = MockRequirement(id: "mockRequirement674")
        let mockRequirement = GroupRequirement(required: true,
                                               requirements: [firstValidRequirement, invalidRequirement, secondValidRequirement],
                                               requirementOperator: .ALL)
        
        
        let content = IssuanceRequestContent(style: mockStyle,
                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                             requirement: mockRequirement,
                                             rootOfTrust: mockRootOfTrust)
        
        let contractIssuanceRequest = ContractIssuanceRequest(content: content,
                                                              issuanceResponseContainer: mockIssuanceResponseContainer,
                                                              verifiedIdRequester: mockVCRequester,
                                                              configuration: configuration)
        
        // Act
        let actualResult = contractIssuanceRequest.isSatisfied()
        
        // Assert
        XCTAssertFalse(actualResult)
    }
    
    func testIsSatisfied_WithOneValidRequirement_ReturnsTrue() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let mockMapper = MockMapper()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let mockVCRequester = MockVerifiedIdRequester()
        let mockIssuanceResponseContainer = MockIssuanceResponseContainer()
        
        let validRequirement = MockRequirement(id: "mockRequirement324")
        
        let content = IssuanceRequestContent(style: mockStyle,
                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                             requirement: validRequirement,
                                             rootOfTrust: mockRootOfTrust)
        
        let contractIssuanceRequest = ContractIssuanceRequest(content: content,
                                                              issuanceResponseContainer: mockIssuanceResponseContainer,
                                                              verifiedIdRequester: mockVCRequester,
                                                              configuration: configuration)
        
        // Act
        let actualResult = contractIssuanceRequest.isSatisfied()
        
        // Assert
        XCTAssert(actualResult)
    }
    
    func testIsSatisfied_WithMultipleValidRequirements_ReturnsTrue() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let mockMapper = MockMapper()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let mockVCRequester = MockVerifiedIdRequester()
        let mockIssuanceResponseContainer = MockIssuanceResponseContainer()
        
        let firstValidRequirement = MockRequirement(id: "mockRequirement634")
        let secondValidRequirement = MockRequirement(id: "mockRequirement674")
        let thirdValidRequirement = MockRequirement(id: "mockRequirement694")
        let mockRequirement = GroupRequirement(required: true,
                                               requirements: [firstValidRequirement, secondValidRequirement, thirdValidRequirement],
                                               requirementOperator: .ALL)
        
        let content = IssuanceRequestContent(style: mockStyle,
                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                             requirement: mockRequirement,
                                             rootOfTrust: mockRootOfTrust)
        
        let contractIssuanceRequest = ContractIssuanceRequest(content: content,
                                                              issuanceResponseContainer: mockIssuanceResponseContainer,
                                                              verifiedIdRequester: mockVCRequester,
                                                              configuration: configuration)
        
        // Act
        let actualResult = contractIssuanceRequest.isSatisfied()
        
        // Assert
        XCTAssert(actualResult)
    }
    
    func testComplete_WithSuccessfulIssuance_ReturnVerifiedId() async throws {
        // Arrange
        let expectedVerifiedId = MockVerifiedId(id: "mockVerifiedId", issuedOn: Date())
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let mockRequirement = MockRequirement(id: "mockRequirement634")
        let mockMapper = MockMapper()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let mockVCRequester = MockVerifiedIdRequester(sendRequestCallback: { _ in expectedVerifiedId })
        
        func mockAddRequirementCallback(requirement: Requirement) throws {
            XCTAssertEqual(requirement as? MockRequirement, mockRequirement)
        }
        
        let mockIssuanceResponseContainer = MockIssuanceResponseContainer(mockAddRequirementCallback: mockAddRequirementCallback)
        
        let content = IssuanceRequestContent(style: mockStyle,
                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                             requirement: mockRequirement,
                                             rootOfTrust: mockRootOfTrust)
        
        let contractIssuanceRequest = ContractIssuanceRequest(content: content,
                                                              issuanceResponseContainer: mockIssuanceResponseContainer,
                                                              verifiedIdRequester: mockVCRequester,
                                                              configuration: configuration)
        
        // Act
        let actualResult = await contractIssuanceRequest.complete()
        
        // Assert
        switch (actualResult) {
        case .success(let verifiedId):
            XCTAssertEqual(verifiedId as? MockVerifiedId, expectedVerifiedId)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testComplete_WithUnsuccessfulIssuance_ReturnsError() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let mockRequirement = MockRequirement(id: "mockRequirement634")
        let mockMapper = MockMapper()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let mockVCRequester = MockVerifiedIdRequester(sendRequestCallback: { _ in throw ExpectedError.expectedToBeThrown })
        
        func mockAddRequirementCallback(requirement: Requirement) throws {
            XCTAssertEqual(requirement as? MockRequirement, mockRequirement)
        }
        
        let mockIssuanceResponseContainer = MockIssuanceResponseContainer(mockAddRequirementCallback: mockAddRequirementCallback)
        
        let content = IssuanceRequestContent(style: mockStyle,
                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                             requirement: mockRequirement,
                                             rootOfTrust: mockRootOfTrust)
        
        let contractIssuanceRequest = ContractIssuanceRequest(content: content,
                                                              issuanceResponseContainer: mockIssuanceResponseContainer,
                                                              verifiedIdRequester: mockVCRequester,
                                                              configuration: configuration)
        
        // Act
        let actualResult = await contractIssuanceRequest.complete()
        
        // Assert
        switch (actualResult) {
        case .success(_):
            XCTFail("Should have thrown an error.")
        case .failure(let error):
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, .expectedToBeThrown)
        }
    }
}
