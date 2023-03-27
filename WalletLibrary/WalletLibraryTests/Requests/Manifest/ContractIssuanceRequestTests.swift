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
        let mockState = "mockState"
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        var wasSendIssuanceResultCallbackCalled: Bool = false
        
        func mockSendIssuanceResultCallback(result: IssuanceCompletionResponse) throws {
            XCTAssertEqual(result.state, mockState)
            XCTAssertEqual(result.code, "issuance_successful")
            XCTAssertNil(result.details)
            wasSendIssuanceResultCallbackCalled = true
        }
        
        let mockVCRequester = MockVerifiedIdRequester(sendRequestCallback: { _ in expectedVerifiedId },
                                                      sendIssuanceResultCallback: mockSendIssuanceResultCallback)
        
        func mockAddRequirementCallback(requirement: Requirement) throws {
            XCTAssertEqual(requirement as? MockRequirement, mockRequirement)
        }
        
        let mockIssuanceResponseContainer = MockIssuanceResponseContainer(mockAddRequirementCallback: mockAddRequirementCallback)
        
        let content = IssuanceRequestContent(style: mockStyle,
                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                             requirement: mockRequirement,
                                             requestState: mockState,
                                             issuanceResultCallbackUrl: URL(string: "https://test.com")!,
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
            XCTAssert(wasSendIssuanceResultCallbackCalled)
            XCTAssertEqual(verifiedId as? MockVerifiedId, expectedVerifiedId)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testComplete_WithSuccessfulIssuanceAndNoStateOrCallback_ReturnVerifiedId() async throws {
        // Arrange
        let expectedVerifiedId = MockVerifiedId(id: "mockVerifiedId", issuedOn: Date())
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let mockRequirement = MockRequirement(id: "mockRequirement634")
        let mockMapper = MockMapper()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        var wasSendIssuanceResultCallbackCalled: Bool = false
        
        func mockSendIssuanceResultCallback(result: IssuanceCompletionResponse) throws {
            wasSendIssuanceResultCallbackCalled = true
        }
        
        let mockVCRequester = MockVerifiedIdRequester(sendRequestCallback: { _ in expectedVerifiedId },
                                                      sendIssuanceResultCallback: mockSendIssuanceResultCallback)
        
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
            XCTAssertFalse(wasSendIssuanceResultCallbackCalled)
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
        let mockState = "mockState"
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        var wasSendIssuanceResultCallbackCalled: Bool = false
        
        func mockSendIssuanceResultCallback(result: IssuanceCompletionResponse) throws {
            XCTAssertEqual(result.state, mockState)
            XCTAssertEqual(result.code, "issuance_failed")
            XCTAssertEqual(result.details, "issuance_service_error")
            wasSendIssuanceResultCallbackCalled = true
        }
        
        let mockVCRequester = MockVerifiedIdRequester(sendRequestCallback: { _ in throw ExpectedError.expectedToBeThrown },
                                                      sendIssuanceResultCallback: mockSendIssuanceResultCallback)
        
        func mockAddRequirementCallback(requirement: Requirement) throws {
            XCTAssertEqual(requirement as? MockRequirement, mockRequirement)
        }
        
        let mockIssuanceResponseContainer = MockIssuanceResponseContainer(mockAddRequirementCallback: mockAddRequirementCallback)
        
        let content = IssuanceRequestContent(style: mockStyle,
                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                             requirement: mockRequirement,
                                             requestState: mockState,
                                             issuanceResultCallbackUrl: URL(string: "https://test.com")!,
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
            XCTAssert(wasSendIssuanceResultCallbackCalled)
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, .expectedToBeThrown)
        }
    }
    
    func testComplete_WithUnsuccessfulIssuanceAndNoStateOrCallback_ReturnsError() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let mockRequirement = MockRequirement(id: "mockRequirement634")
        let mockMapper = MockMapper()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        var wasSendIssuanceResultCallbackCalled: Bool = false
        
        func mockSendIssuanceResultCallback(result: IssuanceCompletionResponse) throws {
            wasSendIssuanceResultCallbackCalled = true
        }
        
        let mockVCRequester = MockVerifiedIdRequester(sendRequestCallback: { _ in throw ExpectedError.expectedToBeThrown },
                                                      sendIssuanceResultCallback: mockSendIssuanceResultCallback)
        
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
            XCTAssertFalse(wasSendIssuanceResultCallbackCalled)
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, .expectedToBeThrown)
        }
    }
    
    func testCancel_WithMissingState_ReturnsError() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let mockRequirement = MockRequirement(id: "mockRequirement634")
        let mockMapper = MockMapper()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        var wasSendIssuanceResultCallbackCalled: Bool = false
        
        func mockSendIssuanceResultCallback(result: IssuanceCompletionResponse) throws {
            wasSendIssuanceResultCallbackCalled = true
        }
        
        let mockVCRequester = MockVerifiedIdRequester(sendIssuanceResultCallback: mockSendIssuanceResultCallback)
        
        func mockAddRequirementCallback(requirement: Requirement) throws {
            XCTAssertEqual(requirement as? MockRequirement, mockRequirement)
        }
        
        let mockIssuanceResponseContainer = MockIssuanceResponseContainer(mockAddRequirementCallback: mockAddRequirementCallback)
        
        let content = IssuanceRequestContent(style: mockStyle,
                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                             requirement: mockRequirement,
                                             issuanceResultCallbackUrl: URL(string: "https://test.com")!,
                                             rootOfTrust: mockRootOfTrust)
        
        let contractIssuanceRequest = ContractIssuanceRequest(content: content,
                                                              issuanceResponseContainer: mockIssuanceResponseContainer,
                                                              verifiedIdRequester: mockVCRequester,
                                                              configuration: configuration)
        
        // Act
        let actualResult = await contractIssuanceRequest.cancel()
        
        // Assert
        switch (actualResult) {
        case .success(_):
            XCTFail("Should have failed")
        case .failure(let error):
            XCTAssertFalse(wasSendIssuanceResultCallbackCalled)
            XCTAssert(error is VerifiedIdIssuanceRequestError)
            XCTAssertEqual(error as? VerifiedIdIssuanceRequestError, .missingRequestStateForIssuanceResultCallback)
        }
    }
    
    func testCancel_WithMissingCallbackUrl_ReturnsError() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let mockRequirement = MockRequirement(id: "mockRequirement634")
        let mockMapper = MockMapper()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        var wasSendIssuanceResultCallbackCalled: Bool = false
        
        func mockSendIssuanceResultCallback(result: IssuanceCompletionResponse) throws {
            wasSendIssuanceResultCallbackCalled = true
        }
        
        let mockVCRequester = MockVerifiedIdRequester(sendIssuanceResultCallback: mockSendIssuanceResultCallback)
        
        func mockAddRequirementCallback(requirement: Requirement) throws {
            XCTAssertEqual(requirement as? MockRequirement, mockRequirement)
        }
        
        let mockIssuanceResponseContainer = MockIssuanceResponseContainer(mockAddRequirementCallback: mockAddRequirementCallback)
        
        let content = IssuanceRequestContent(style: mockStyle,
                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                             requirement: mockRequirement,
                                             requestState: "mockState",
                                             rootOfTrust: mockRootOfTrust)
        
        let contractIssuanceRequest = ContractIssuanceRequest(content: content,
                                                              issuanceResponseContainer: mockIssuanceResponseContainer,
                                                              verifiedIdRequester: mockVCRequester,
                                                              configuration: configuration)
        
        // Act
        let actualResult = await contractIssuanceRequest.cancel()
        
        // Assert
        switch (actualResult) {
        case .success(_):
            XCTFail("Should have failed")
        case .failure(let error):
            XCTAssertFalse(wasSendIssuanceResultCallbackCalled)
            XCTAssert(error is VerifiedIdIssuanceRequestError)
            XCTAssertEqual(error as? VerifiedIdIssuanceRequestError, .missingCallbackURLForIssuanceResultCallback)
        }
    }
    
    func testCancel_WithValidInput_ReturnsSuccess() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let mockRequirement = MockRequirement(id: "mockRequirement634")
        let mockMapper = MockMapper()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let mockState = "mockState"
        var wasSendIssuanceResultCallbackCalled: Bool = false
        
        func mockSendIssuanceResultCallback(result: IssuanceCompletionResponse) throws {
            XCTAssertEqual(result.state, mockState)
            XCTAssertEqual(result.code, "issuance_failed")
            XCTAssertEqual(result.details, "user_canceled")
            wasSendIssuanceResultCallbackCalled = true
        }
        
        let mockVCRequester = MockVerifiedIdRequester(sendIssuanceResultCallback: mockSendIssuanceResultCallback)
        
        func mockAddRequirementCallback(requirement: Requirement) throws {
            XCTAssertEqual(requirement as? MockRequirement, mockRequirement)
        }
        
        let mockIssuanceResponseContainer = MockIssuanceResponseContainer(mockAddRequirementCallback: mockAddRequirementCallback)
        
        let content = IssuanceRequestContent(style: mockStyle,
                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                             requirement: mockRequirement,
                                             requestState: mockState,
                                             issuanceResultCallbackUrl: URL(string: "https://test.com")!,
                                             rootOfTrust: mockRootOfTrust)
        
        let contractIssuanceRequest = ContractIssuanceRequest(content: content,
                                                              issuanceResponseContainer: mockIssuanceResponseContainer,
                                                              verifiedIdRequester: mockVCRequester,
                                                              configuration: configuration)
        
        // Act
        let actualResult = await contractIssuanceRequest.cancel()
        
        // Assert
        switch (actualResult) {
        case .success(_):
            XCTAssert(wasSendIssuanceResultCallbackCalled)
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }
}
