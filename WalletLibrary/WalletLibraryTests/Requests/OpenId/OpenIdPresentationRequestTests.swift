/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenIdPresentationRequestTests: XCTestCase 
{
    enum ExpectedError: Error, Equatable 
    {
        case expectedToBeThrown
        case expectedToBeThrownInResponder
    }
    
    func testIsSatisfied_WithInvalidRequirement_ReturnsFalse() async throws
    {
        // Arrange
        let mockRawOpenIdRequest = createMockRawOpenIdRequest(responseURL: nil)
        
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let peSerializer = try PresentationExchangeSerializer(request: mockRawOpenIdRequest,
                                                              libraryConfiguration: configuration)
        
        let requirement = MockRequirement(id: "test",
                                          mockValidateCallback: { throw ExpectedError.expectedToBeThrown })
        
        let request = OpenIdPresentationRequest(partialRequest: createMockPartialRequest(requirement),
                                                rawRequest: mockRawOpenIdRequest,
                                                openIdResponder: MockOpenIdResponder(),
                                                configuration: configuration,
                                                requestProcessorSerializer: peSerializer,
                                                verifiedIdSerializer: VerifiableCredentialSerializer())
        
        // Act
        let actualResult = request.isSatisfied()
        
        // Assert
        XCTAssertFalse(actualResult)
    }
    
    func testIsSatisfied_WithValidRequirement_ReturnsTrue() async throws 
    {
        // Arrange
        let mockRawOpenIdRequest = createMockRawOpenIdRequest(responseURL: nil)
        
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let peSerializer = try PresentationExchangeSerializer(request: mockRawOpenIdRequest,
                                                              libraryConfiguration: configuration)
        
        let request = OpenIdPresentationRequest(partialRequest: createMockPartialRequest(),
                                                rawRequest: mockRawOpenIdRequest,
                                                openIdResponder: MockOpenIdResponder(),
                                                configuration: configuration,
                                                requestProcessorSerializer: peSerializer,
                                                verifiedIdSerializer: VerifiableCredentialSerializer())
        
        // Act
        let actualResult = request.isSatisfied()
        
        // Assert
        XCTAssert(actualResult)
    }
    
    func testComplete_WithSerializationFFOnNoRedirectURL_ThrowsError() async throws
    {
        // Arrange
        let mockRawOpenIdRequest = createMockRawOpenIdRequest(responseURL: nil)
        
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let peSerializer = try PresentationExchangeSerializer(request: mockRawOpenIdRequest,
                                                              libraryConfiguration: configuration)
        
        let request = OpenIdPresentationRequest(partialRequest: createMockPartialRequest(),
                                                rawRequest: mockRawOpenIdRequest,
                                                openIdResponder: MockOpenIdResponder(),
                                                configuration: configuration,
                                                requestProcessorSerializer: peSerializer,
                                                verifiedIdSerializer: VerifiableCredentialSerializer())
        
        // Act
        let actualResult = await request.complete()
        
        // Assert
        switch (actualResult) 
        {
        case .success(_):
            XCTFail()
        case .failure(let error):
            guard let peError = error as? PresentationExchangeError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(peError.code, "missing_required_property")
            XCTAssertEqual(peError.message, "Missing response URL on request.")
        }
    }
    
    func testComplete_WithSerializationWithInvalidPESerializer_ThrowsError() async throws
    {
        // Arrange
        let mockRawOpenIdRequest = createMockRawOpenIdRequest()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let mockRequestSerializer = MockRequestProcessorSerializer()
        
        let request = OpenIdPresentationRequest(partialRequest: createMockPartialRequest(),
                                                rawRequest: mockRawOpenIdRequest,
                                                openIdResponder: MockOpenIdResponder(),
                                                configuration: configuration,
                                                requestProcessorSerializer: mockRequestSerializer,
                                                verifiedIdSerializer: VerifiableCredentialSerializer())
        
        // Act
        let actualResult = await request.complete()
        
        // Assert
        switch (actualResult)
        {
        case .success(_):
            XCTFail()
        case .failure(let error):
            guard let peError = error as? PresentationExchangeError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(peError.code, "missing_required_property")
            XCTAssertEqual(peError.message, "Presentation Exchange Serializer is invalid or nil.")
        }
    }
    
    func testComplete_WithSerializationWithInvalidVerifiedIdSerializer_ThrowsError() async throws
    {
        // Arrange
        let mockRawOpenIdRequest = createMockRawOpenIdRequest()
        
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let mockVerifiedIdSerializer = MockVerifiedIdSerializer<String>()
        
        let request = OpenIdPresentationRequest(partialRequest: createMockPartialRequest(),
                                                rawRequest: mockRawOpenIdRequest,
                                                openIdResponder: MockOpenIdResponder(),
                                                configuration: configuration,
                                                requestProcessorSerializer: MockRequestProcessorSerializer(),
                                                verifiedIdSerializer: mockVerifiedIdSerializer)
        
        // Act
        let actualResult = await request.complete()
        
        // Assert
        switch (actualResult)
        {
        case .success(_):
            XCTFail()
        case .failure(let error):
            guard let peError = error as? PresentationExchangeError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(peError.code, "missing_required_property")
            XCTAssertEqual(peError.message, "Verifiable Credential Serializer is invalid or nil.")
        }
    }
    
    func testComplete_WithSerializationAndSerializerThrows_ThrowsError() async throws
    {
        // Arrange
        let mockRawOpenIdRequest = createMockRawOpenIdRequest()
        
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let expectedError = VerifiedIdError(message: "expected to throw.", code: "expected_to_throw")
        let peSerializer = try MockPresentationExchangeSerializer(expectedSerializationErrorToThrow: expectedError)
        
        let request = OpenIdPresentationRequest(partialRequest: createMockPartialRequest(),
                                                rawRequest: mockRawOpenIdRequest,
                                                openIdResponder: MockOpenIdResponder(),
                                                configuration: configuration,
                                                requestProcessorSerializer: peSerializer,
                                                verifiedIdSerializer: VerifiableCredentialSerializer())
        
        // Act
        let actualResult = await request.complete()
        
        // Assert
        switch (actualResult)
        {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(expectedError.message, error.message)
            XCTAssertEqual(expectedError.code, error.code)
        }
    }
    
    func testComplete_WithSerializationAndBuildThrows_ThrowsError() async throws
    {
        // Arrange
        let mockRawOpenIdRequest = createMockRawOpenIdRequest()

        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let expectedError = VerifiedIdError(message: "expected to throw.", code: "expected_to_throw")
        let peSerializer = try MockPresentationExchangeSerializer(expectedBuildErrorToThrow: expectedError)
        
        let request = OpenIdPresentationRequest(partialRequest: createMockPartialRequest(),
                                                rawRequest: mockRawOpenIdRequest,
                                                openIdResponder: MockOpenIdResponder(),
                                                configuration: configuration,
                                                requestProcessorSerializer: peSerializer,
                                                verifiedIdSerializer: VerifiableCredentialSerializer())
        
        // Act
        let actualResult = await request.complete()
        
        // Assert
        switch (actualResult)
        {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(expectedError.message, error.message)
            XCTAssertEqual(expectedError.code, error.code)
        }
    }
    
    func testComplete_WithSerializationAndSucceeds_ReturnsVoid() async throws
    {
        // Arrange
        let mockRawOpenIdRequest = createMockRawOpenIdRequest()
        
        let mockNetworkingLayer = MockLibraryNetworking.create(expectedResults: [("", PostPresentationResponseOperation.self)])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(),
                                                 networking: mockNetworkingLayer)
        
        let peSerializer = try MockPresentationExchangeSerializer()
        
        let request = OpenIdPresentationRequest(partialRequest: createMockPartialRequest(),
                                                rawRequest: mockRawOpenIdRequest,
                                                openIdResponder: MockOpenIdResponder(),
                                                configuration: configuration,
                                                requestProcessorSerializer: peSerializer,
                                                verifiedIdSerializer: VerifiableCredentialSerializer())
        
        // Act
        let actualResult = await request.complete()
        
        // Assert
        switch (actualResult)
        {
        case .success(_):
            XCTAssert(true)
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }
    
    private func createMockPresentationRequest(requestedVPTokens: [RequestedVPToken] = [],
                                               expectedRedirectURL: String? = "expectedAudienceUrl") -> PresentationRequest
    {
        let mockClaims = PresentationRequestClaims(jti: "",
                                                   clientID: "expectedAudienceDid",
                                                   redirectURI: expectedRedirectURL,
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
    
    private func createMockRawOpenIdRequest(responseURL: URL? = URL(string: "microsoft.com")) -> any OpenIdRawRequest
    {
        return MockOpenIdRawRequest(nonce: "mockNonce",
                                    state: "mockState",
                                    clientId: "mockClientId",
                                    definitionId: "mockDefinitionId",
                                    responseURL: responseURL)
    }
    
    private func createMockPartialRequest(_ requirement: Requirement? = nil) -> VerifiedIdPartialRequest
    {
        let mockPartialRequest = VerifiedIdPartialRequest(requesterStyle: MockRequesterStyle(requester: "mockRequester"),
                                                          requirement: requirement ?? MockRequirement(id: "mockRequirement"),
                                                          rootOfTrust: RootOfTrust(verified: false, source: nil))
        return mockPartialRequest
    }
}
