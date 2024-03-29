/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenIdPresentationRequestTests: XCTestCase {
    
    enum ExpectedError: Error, Equatable {
        case expectedToBeThrown
        case expectedToBeThrownInResponder
    }
    
    func testIsSatisfied_WithInvalidRequirement_ReturnsFalse() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let mockRequirement = MockRequirement(id: "mockRequirement324",
                                              mockValidateCallback: { throw ExpectedError.expectedToBeThrown })
        
        let content = PresentationRequestContent(style: mockStyle,
                                                 requirement: mockRequirement,
                                                 rootOfTrust: mockRootOfTrust,
                                                 requestState: "mock state",
                                                 callbackUrl: URL(string: "https://test.com")!)
        
        let mockResponder = MockOpenIdResponder()
        
        let request = OpenIdPresentationRequest(content: content,
                                                rawRequest: MockOpenIdRawRequest(raw: nil),
                                                openIdResponder: mockResponder,
                                                configuration: configuration)
        
        // Act
        let actualResult = request.isSatisfied()
        
        // Assert
        XCTAssertFalse(actualResult)
    }
    
    func testIsSatisfied_WithValidRequirement_ReturnsTrue() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let mockRequirement = MockRequirement(id: "mockRequirement324")
        
        let content = PresentationRequestContent(style: mockStyle,
                                                 requirement: mockRequirement,
                                                 rootOfTrust: mockRootOfTrust,
                                                 requestState: "mock state",
                                                 callbackUrl: URL(string: "https://test.com")!)
        
        let mockResponder = MockOpenIdResponder()
        
        let request = OpenIdPresentationRequest(content: content,
                                                rawRequest: MockOpenIdRawRequest(raw: nil),
                                                openIdResponder: mockResponder,
                                                configuration: configuration)
        
        // Act
        let actualResult = request.isSatisfied()
        
        // Assert
        XCTAssert(actualResult)
    }
    
    func testComplete_WithPresentationResponseContainerThrows_ReturnsFailureResult() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let mockRequirement = MockRequirement(id: "mockRequirement324")
        
        let content = PresentationRequestContent(style: mockStyle,
                                                 requirement: mockRequirement,
                                                 rootOfTrust: mockRootOfTrust,
                                                 requestState: "mock state",
                                                 callbackUrl: URL(string: "https://test.com")!)
        
        let mockResponder = MockOpenIdResponder()
        
        let request = OpenIdPresentationRequest(content: content,
                                                rawRequest: MockOpenIdRawRequest(raw: nil),
                                                openIdResponder: mockResponder,
                                                configuration: configuration)
        
        // Act
        let actualResult = await request.complete()
        
        // Assert
        switch (actualResult) {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssert(error is UnspecifiedVerifiedIdError)
            XCTAssertEqual((error as? UnspecifiedVerifiedIdError)?.error as? PresentationResponseContainerError,
                           .unableToCastVCSDKPresentationRequestFromRawRequestOfType("MockOpenIdRawRequest"))
        }
    }
    
    func testComplete_WithAddRequirementToPresentationResponseThrows_ReturnsFailureResult() async throws {
        // Arrange
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let mockRequirement = MockRequirement(id: "mockRequirement324")
        
        let content = PresentationRequestContent(style: mockStyle,
                                                 requirement: mockRequirement,
                                                 rootOfTrust: mockRootOfTrust,
                                                 requestState: "mock state",
                                                 callbackUrl: URL(string: "https://test.com")!)
        
        let mockResponder = MockOpenIdResponder()
        
        let mockRawRequest = createMockPresentationRequest()
        
        let request = OpenIdPresentationRequest(content: content,
                                                rawRequest: mockRawRequest,
                                                openIdResponder: mockResponder,
                                                configuration: configuration)
        
        // Act
        let actualResult = await request.complete()
        
        // Assert
        switch (actualResult) {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssert(error is UnspecifiedVerifiedIdError)
            XCTAssertEqual((error as? UnspecifiedVerifiedIdError)?.error as? PresentationResponseContainerError,
                           .unsupportedRequirementOfType("MockRequirement"))
        }
    }
    
    func testComplete_WithResponderThrows_ReturnsFailureResult() async throws {
        // Arrange
        let mockInputDescriptor = PresentationInputDescriptor(id: "mockId",
                                                              schema: [],
                                                              issuanceMetadata: [],
                                                              name: nil,
                                                              purpose: nil,
                                                              constraints: nil)
        let mockPresentationDefinition = PresentationDefinition(id: "mock id",
                                                                inputDescriptors: [mockInputDescriptor],
                                                                issuance: nil)
        let requestedVpToken = RequestedVPToken(presentationDefinition: mockPresentationDefinition)
        let mockPresentationRequest = createMockPresentationRequest(requestedVPTokens: [requestedVpToken])
        
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let mockRequirement = VerifiedIdRequirement(encrypted: false,
                                                    required: true,
                                                    types: [],
                                                    purpose: nil,
                                                    issuanceOptions: [],
                                                    id: "mockId",
                                                    constraint: MockConstraint(doesMatchResult: true))
        let mockVC = MockVerifiableCredentialHelper().createMockVerifiableCredential()
        try mockRequirement.fulfill(with: mockVC).get()
        
        let content = PresentationRequestContent(style: mockStyle,
                                                 requirement: mockRequirement,
                                                 rootOfTrust: mockRootOfTrust,
                                                 requestState: "mock state",
                                                 callbackUrl: URL(string: "https://test.com")!)
        
        func mockSend(response: RawPresentationResponse) async throws {
            throw ExpectedError.expectedToBeThrownInResponder
        }
        
        let mockResponder = MockOpenIdResponder(mockSend: mockSend)
        
        let request = OpenIdPresentationRequest(content: content,
                                                rawRequest: mockPresentationRequest,
                                                openIdResponder: mockResponder,
                                                configuration: configuration)
        
        // Act
        let actualResult = await request.complete()
        
        // Assert
        switch (actualResult) {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssert(error is UnspecifiedVerifiedIdError)
            XCTAssertEqual((error as? UnspecifiedVerifiedIdError)?.error as? ExpectedError,
                           .expectedToBeThrownInResponder)
        }
    }
    
    func testComplete_WithValidInput_ReturnsSuccessResult() async throws {
        // Arrange
        let mockInputDescriptor = PresentationInputDescriptor(id: "mockId",
                                                              schema: [],
                                                              issuanceMetadata: [],
                                                              name: nil,
                                                              purpose: nil,
                                                              constraints: nil)
        let mockPresentationDefinition = PresentationDefinition(id: "mock id",
                                                                inputDescriptors: [mockInputDescriptor],
                                                                issuance: nil)
        let requestedVpToken = RequestedVPToken(presentationDefinition: mockPresentationDefinition)
        let mockPresentationRequest = createMockPresentationRequest(requestedVPTokens: [requestedVpToken])
        
        let mockStyle = MockRequesterStyle(requester: "mock requester")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "")
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let mockRequirement = VerifiedIdRequirement(encrypted: false,
                                                    required: true,
                                                    types: [],
                                                    purpose: nil,
                                                    issuanceOptions: [],
                                                    id: "mockId",
                                                    constraint: MockConstraint(doesMatchResult: true))
        let mockVC = MockVerifiableCredentialHelper().createMockVerifiableCredential()
        try mockRequirement.fulfill(with: mockVC).get()
        
        let content = PresentationRequestContent(style: mockStyle,
                                                 requirement: mockRequirement,
                                                 rootOfTrust: mockRootOfTrust,
                                                 requestState: "mock state",
                                                 callbackUrl: URL(string: "https://test.com")!)
        
        let mockResponder = MockOpenIdResponder()
        
        let request = OpenIdPresentationRequest(content: content,
                                                rawRequest: mockPresentationRequest,
                                                openIdResponder: mockResponder,
                                                configuration: configuration)
        
        // Act
        let actualResult = await request.complete()
        
        // Assert
        switch (actualResult) {
        case .success(_):
            XCTAssert(true)
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }
    
    private func createMockPresentationRequest(requestedVPTokens: [RequestedVPToken] = []) -> PresentationRequest {
        let mockClaims = PresentationRequestClaims(jti: "",
                                                   clientID: "expectedAudienceDid",
                                                   redirectURI: "expectedAudienceUrl",
                                                   responseMode: "",
                                                   responseType: "",
                                                   claims: RequestedClaims(vpToken: requestedVPTokens),
                                                   state: "",
                                                   nonce: "expectedNonce",
                                                   scope: "",
                                                   prompt: "",
                                                   registration: nil,
                                                   iat: nil,
                                                   exp: nil,
                                                   pin: nil)
        let mockToken = PresentationRequestToken(headers: Header(), content: mockClaims)!
        let rawPresentationRequest = PresentationRequest(from: mockToken, linkedDomainResult: LinkedDomainResult.linkedDomainMissing)
        return rawPresentationRequest
    }
}
