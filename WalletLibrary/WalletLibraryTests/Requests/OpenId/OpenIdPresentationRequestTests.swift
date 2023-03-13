/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
import VCToken
@testable import WalletLibrary

struct MockOpenIdResponder: OpenIdResponder {
    
    let mockSend: ((WalletLibrary.PresentationResponse) async throws -> ())?
    
    init(mockSend: ((WalletLibrary.PresentationResponse) async throws -> ())? = nil) {
        self.mockSend = mockSend
    }
    func send(response: WalletLibrary.PresentationResponse) async throws {
        try await self.mockSend?(response)
    }
}

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
                                                 rootOfTrust: mockRootOfTrust)
        
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
                                                 rootOfTrust: mockRootOfTrust)
        
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
                                                 rootOfTrust: mockRootOfTrust)
        
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
            XCTAssert(error is PresentationResponseError)
            XCTAssertEqual((error as? PresentationResponseError),
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
                                                 rootOfTrust: mockRootOfTrust)
        
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
            XCTAssert(error is PresentationResponseError)
            XCTAssertEqual((error as? PresentationResponseError),
                           .unsupportedRequirementOfType("MockRequirement"))
        }
    }
    
    func testComplete_WithResponderThrows_ReturnsFailureResult() async throws {
        // Arrange
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
        mockRequirement.selectedVerifiedId = MockVerifiableCredentialHelper().createMockVerifiableCredential()
        
        let content = PresentationRequestContent(style: mockStyle,
                                                 requirement: mockRequirement,
                                                 rootOfTrust: mockRootOfTrust)
        
        func mockSend(response: WalletLibrary.PresentationResponse) async throws {
            throw ExpectedError.expectedToBeThrownInResponder
        }
        
        let mockResponder = MockOpenIdResponder(mockSend: mockSend)
        
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
            print(error)
            XCTAssert(error is ExpectedError)
            XCTAssertEqual((error as? ExpectedError), .expectedToBeThrownInResponder)
        }
    }
    
    func testComplete_WithValidInput_ReturnsSuccessResult() async throws {
        // Arrange
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
        mockRequirement.selectedVerifiedId = MockVerifiableCredentialHelper().createMockVerifiableCredential()
        
        let content = PresentationRequestContent(style: mockStyle,
                                                 requirement: mockRequirement,
                                                 rootOfTrust: mockRootOfTrust)
        
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
            XCTAssert(true)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    private func createMockPresentationRequest() -> PresentationRequest {
        let mockClaims = PresentationRequestClaims(jti: nil,
                                                   clientID: "mockAudienceDID",
                                                   redirectURI: "mockAudienceURL",
                                                   responseMode: nil,
                                                   responseType: nil,
                                                   claims: nil,
                                                   state: nil,
                                                   nonce: "mockNonce",
                                                   scope: nil,
                                                   prompt: nil,
                                                   registration: nil,
                                                   iat: nil,
                                                   exp: nil,
                                                   pin: nil)
        let mockToken = PresentationRequestToken(headers: Header(), content: mockClaims)!
        let mockRawRequest = PresentationRequest(from: mockToken, linkedDomainResult: .linkedDomainMissing)
        return mockRawRequest
    }
}
