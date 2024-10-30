/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenIdPresentationRequestValidatorTests: XCTestCase
{
    func testValidateRequest_WithMalformedRequest_ThrowsError() async throws
    {
        // Arrange
        let mockRootOfTrustResolver = MockRootOfTrustResolver()
        let validator = OpenIdPresentationRequestValidator(rootOfTrustResolver: mockRootOfTrustResolver,
                                                           urlSession: URLSession.shared)
        
        // Act / Assert
        do
        {
            let _ = try await validator.validateRequest(data: Data())
            XCTFail()
        }
        catch
        {
            XCTAssert(error is  MalformedInputError)
            
            guard let malformedInputError = error as? MalformedInputError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(malformedInputError.code, "malformed_input_error")
            XCTAssertEqual(malformedInputError.message, "Input is not a Presentation Request Token.")
        }
    }
    
    func testValidateRequest_WithNoDIDInHeader_ThrowsError() async throws
    {
        // Arrange
        let input = createRawPresentationRequest(expectedKeyId: nil)
        
        let mockRootOfTrustResolver = MockRootOfTrustResolver()
        let mockDiscoveryNetworking = MockDiscoveryApiCalls(resolveSuccessfully: true)
        let mockRequestValidator = MockPresentationRequestValidator(isValid: true)
        let mockLinkedDomainService = LinkedDomainService(rootOfTrustResolver: mockRootOfTrustResolver,
                                                          urlSession: URLSession.shared)
        let validator = OpenIdPresentationRequestValidator(didDocumentDiscoveryApiCalls: mockDiscoveryNetworking,
                                                           requestValidator: mockRequestValidator,
                                                           linkedDomainService: mockLinkedDomainService)
        
        // Act / Assert
        do
        {
            let _ = try await validator.validateRequest(data: input)
            XCTFail()
        }
        catch
        {
            XCTAssert(error is  MalformedInputError)
            
            guard let malformedInputError = error as? MalformedInputError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(malformedInputError.code, "malformed_input_error")
            XCTAssertEqual(malformedInputError.message, "No DID in request header.")
        }
    }
    
    func testValidateRequest_WithUnableToFetchIdentifierDocument_ThrowsError() async throws
    {
        // Arrange
        let input = createRawPresentationRequest()
        
        let mockRootOfTrustResolver = MockRootOfTrustResolver()
        let mockDiscoveryNetworking = MockDiscoveryApiCalls(resolveSuccessfully: false)
        let mockRequestValidator = MockPresentationRequestValidator(isValid: true)
        let mockLinkedDomainService = LinkedDomainService(rootOfTrustResolver: mockRootOfTrustResolver,
                                                          urlSession: URLSession.shared)
        let validator = OpenIdPresentationRequestValidator(didDocumentDiscoveryApiCalls: mockDiscoveryNetworking,
                                                           requestValidator: mockRequestValidator,
                                                           linkedDomainService: mockLinkedDomainService)
        
        // Act / Assert
        do
        {
            let _ = try await validator.validateRequest(data: input)
            XCTFail()
        }
        catch
        {
            XCTAssert(error is  MockDiscoveryNetworkingError)
            XCTAssertEqual(error as? MockDiscoveryNetworkingError, MockDiscoveryNetworkingError.doNotWantToResolveRealObject)
        }
    }
    
    func testValidateRequest_WithNoPublicKeysInDocument_ThrowsError() async throws
    {
        // Arrange
        let input = createRawPresentationRequest()
        let mockIdentifierDocument = IdentifierDocument(service: nil,
                                                        verificationMethod: nil,
                                                        authentication: [],
                                                        id: "mockIdentifierDocument")
        
        let mockRootOfTrustResolver = MockRootOfTrustResolver()
        let mockDiscoveryNetworking = MockDiscoveryApiCalls(withIdentifierDocument: mockIdentifierDocument)
        let mockRequestValidator = MockPresentationRequestValidator(isValid: true)
        let mockLinkedDomainService = LinkedDomainService(rootOfTrustResolver: mockRootOfTrustResolver,
                                                          urlSession: URLSession.shared)
        let validator = OpenIdPresentationRequestValidator(didDocumentDiscoveryApiCalls: mockDiscoveryNetworking,
                                                           requestValidator: mockRequestValidator,
                                                           linkedDomainService: mockLinkedDomainService)
        
        // Act / Assert
        do
        {
            let _ = try await validator.validateRequest(data: input)
            XCTFail()
        }
        catch
        {
            XCTAssert(error is  MalformedInputError)
            
            guard let malformedInputError = error as? MalformedInputError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(malformedInputError.code, "malformed_input_error")
            XCTAssertEqual(malformedInputError.message, "No Public Keys in Identifier Document.")
        }
    }
    
    func testValidateRequest_WhenValidatorsThrows_ThrowsError() async throws
    {
        // Arrange
        let input = createRawPresentationRequest()
        let identifierDocumentPublicKey = IdentifierDocumentPublicKey(id: nil,
                                                                      type: "type",
                                                                      controller: nil,
                                                                      publicKeyJwk: ECPublicJwk(x: "x",
                                                                                                y: "y",
                                                                                                keyId: "keyId"),
                                                                      purposes: nil)
        let mockIdentifierDocument = IdentifierDocument(service: nil,
                                                        verificationMethod: [identifierDocumentPublicKey],
                                                        authentication: [],
                                                        id: "mockIdentifierDocument")
        
        let mockRootOfTrustResolver = MockRootOfTrustResolver()
        let mockDiscoveryNetworking = MockDiscoveryApiCalls(withIdentifierDocument: mockIdentifierDocument)
        let mockRequestValidator = MockPresentationRequestValidator(isValid: false)
        let mockLinkedDomainService = LinkedDomainService(rootOfTrustResolver: mockRootOfTrustResolver,
                                                          urlSession: URLSession.shared)
        let validator = OpenIdPresentationRequestValidator(didDocumentDiscoveryApiCalls: mockDiscoveryNetworking,
                                                           requestValidator: mockRequestValidator,
                                                           linkedDomainService: mockLinkedDomainService)
        
        // Act / Assert
        do
        {
            let _ = try await validator.validateRequest(data: input)
            XCTFail()
        }
        catch
        {
            XCTAssert(error is  MockPresentationRequestValidatorError)
            XCTAssertEqual(error as? MockPresentationRequestValidatorError , MockPresentationRequestValidatorError.isNotValid)
        }
    }
    
    func testValidateRequest_WithValidRequest_ReturnsResponse() async throws
    {
        // Arrange
        let input = createRawPresentationRequest()
        let identifierDocumentPublicKey = IdentifierDocumentPublicKey(id: nil,
                                                                      type: "type",
                                                                      controller: nil,
                                                                      publicKeyJwk: ECPublicJwk(x: "x",
                                                                                                y: "y",
                                                                                                keyId: "keyId"),
                                                                      purposes: nil)
        let mockIdentifierDocument = IdentifierDocument(service: nil,
                                                        verificationMethod: [identifierDocumentPublicKey],
                                                        authentication: [],
                                                        id: "mockIdentifierDocument")
        
        let mockRootOfTrustResolver = MockRootOfTrustResolver()
        let mockDiscoveryNetworking = MockDiscoveryApiCalls(withIdentifierDocument: mockIdentifierDocument)
        let mockRequestValidator = MockPresentationRequestValidator(isValid: true)
        let mockLinkedDomainService = LinkedDomainService(rootOfTrustResolver: mockRootOfTrustResolver,
                                                          urlSession: URLSession.shared)
        let validator = OpenIdPresentationRequestValidator(didDocumentDiscoveryApiCalls: mockDiscoveryNetworking,
                                                           requestValidator: mockRequestValidator,
                                                           linkedDomainService: mockLinkedDomainService)
        
        // Act / Assert
        do
        {
            let result = try await validator.validateRequest(data: input)
            XCTAssert(result is PresentationRequest)
            
            guard let presentationRequest = result as? PresentationRequest else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(try (presentationRequest.token.serialize()).data(using: .utf8), input)
            XCTAssertEqual(presentationRequest.linkedDomainResult, .linkedDomainVerified(domainUrl: "mockSource"))
        }
        catch
        {
            XCTFail()
        }
    }
    
    private func createRawPresentationRequest(expectedKeyId: String? = "did:test:microsoft.com") -> Data
    {
        let request = PresentationRequestClaims(claims: nil)
        let header = Header(keyId: expectedKeyId)
        let token = PresentationRequestToken(headers: header, content: request)!
        return try! token.serialize().data(using: .utf8)!
    }
}
