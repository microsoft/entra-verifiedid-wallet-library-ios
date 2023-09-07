/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationRequestMappingTests: XCTestCase {
    
    enum ExpectedError: Error {
        case expectedToBeThrown
    }
    
    func testMap_WithNoPresentationDefinitionPresent_ThrowsError() throws {
        // Arrange
        let mockRequestedVpToken = RequestedVPToken(presentationDefinition: nil)
        let mockRequestClaims = RequestedClaims(vpToken: [mockRequestedVpToken])
        let token = createPresentationRequestToken(requestedClaims: mockRequestClaims, registration: nil)
        
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let presentationRequest = PresentationRequest(from: token,
                                                      linkedDomainResult: linkedDomainResult)
        
        let mockMapper = MockMapper()
        
        // Act
        XCTAssertThrowsError(try mockMapper.map(presentationRequest)) { error in
            // Assert
            XCTAssert(error is PresentationRequestMappingError)
            XCTAssertEqual(error as? PresentationRequestMappingError, .presentationDefinitionMissingInRequest)
        }
    }
    
    func testMap_WithInvalidPresentationDefinition_ThrowsError() throws {
        // Arrange
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: [RequestedVPToken(presentationDefinition: mockPresentationDefinition)])
        let token = createPresentationRequestToken(requestedClaims: mockRequestClaims, registration: nil)
        
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let presentationRequest = PresentationRequest(from: token,
                                                      linkedDomainResult: linkedDomainResult)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is PresentationDefinition {
                throw ExpectedError.expectedToBeThrown
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Assert
        XCTAssertThrowsError(try mockMapper.map(presentationRequest)) { error in
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, .expectedToBeThrown)
        }
    }
    
    func testMap_WithInvalidRootOfTrust_ThrowsError() throws {
        // Arrange
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: false,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                                        constraintOperator: .ALL))
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: [RequestedVPToken(presentationDefinition: mockPresentationDefinition)])
        let token = createPresentationRequestToken(requestedClaims: mockRequestClaims, registration: nil)
        
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let presentationRequest = PresentationRequest(from: token,
                                                      linkedDomainResult: linkedDomainResult)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            
            if objectToBeMapped is PresentationDefinition {
                return expectedVerifiedIdRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                throw ExpectedError.expectedToBeThrown
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Act / Assert
        XCTAssertThrowsError(try mockMapper.map(presentationRequest)) { error in
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, .expectedToBeThrown)
        }
    }
    
    func testMap_WithNoClientNamePresent_ReturnVerifiedIdRequestContent() throws {
        // Arrange
        let expectedStyle = OpenIdVerifierStyle(name: "", logo: nil)
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: false,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                              constraintOperator: .ALL))
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: [RequestedVPToken(presentationDefinition: mockPresentationDefinition)])
        let mockRegistration = RegistrationClaims(clientName: nil,
                                                  clientPurpose: nil,
                                                  logoURI: nil,
                                                  subjectIdentifierTypesSupported: nil,
                                                  vpFormats: nil)
        let token = createPresentationRequestToken(requestedClaims: mockRequestClaims, registration: mockRegistration)
        
        let expectedRootOfTrust = RootOfTrust(verified: false, source: "")
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let presentationRequest = PresentationRequest(from: token,
                                                      linkedDomainResult: linkedDomainResult)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            
            if objectToBeMapped is PresentationDefinition {
                return expectedVerifiedIdRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                return expectedRootOfTrust
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mockMapper.map(presentationRequest)
        
        // Act
        XCTAssertIdentical(actualResult.requirement as AnyObject, expectedVerifiedIdRequirement as AnyObject)
        XCTAssertEqual(actualResult.rootOfTrust, expectedRootOfTrust)
        XCTAssertEqual(actualResult.style as? OpenIdVerifierStyle, expectedStyle)
        XCTAssertEqual(actualResult.callbackUrl.absoluteString, "https://test.com")
        XCTAssertEqual(actualResult.requestState, "mockState")
        XCTAssertNil(actualResult.injectedIdToken)
    }
    
    func testMap_WithNoCallbackUrlPresent_ThrowError() throws {
        // Arrange
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: false,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                              constraintOperator: .ALL))
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: [RequestedVPToken(presentationDefinition: mockPresentationDefinition)])
        let mockRegistration = RegistrationClaims(clientName: nil,
                                                  clientPurpose: nil,
                                                  logoURI: nil,
                                                  subjectIdentifierTypesSupported: nil,
                                                  vpFormats: nil)
        let token = createPresentationRequestToken(requestedClaims: mockRequestClaims,
                                                   registration: mockRegistration,
                                                   callbackUrl: nil)
        
        let expectedRootOfTrust = RootOfTrust(verified: false, source: "")
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let presentationRequest = PresentationRequest(from: token,
                                                      linkedDomainResult: linkedDomainResult)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            
            if objectToBeMapped is PresentationDefinition {
                return expectedVerifiedIdRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                return expectedRootOfTrust
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Act / Assert
        XCTAssertThrowsError(try mockMapper.map(presentationRequest)) { error in
            // Assert
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: "redirectUri", in: "PresentationRequest"))
        }
    }
    
    func testMap_WithCallbackMalformed_ThrowError() throws {
        // Arrange
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: false,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                              constraintOperator: .ALL))
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: [RequestedVPToken(presentationDefinition: mockPresentationDefinition)])
        let mockRegistration = RegistrationClaims(clientName: nil,
                                                  clientPurpose: nil,
                                                  logoURI: nil,
                                                  subjectIdentifierTypesSupported: nil,
                                                  vpFormats: nil)
        let token = createPresentationRequestToken(requestedClaims: mockRequestClaims,
                                                   registration: mockRegistration,
                                                   callbackUrl: "//|\\")
        
        let expectedRootOfTrust = RootOfTrust(verified: false, source: "")
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let presentationRequest = PresentationRequest(from: token,
                                                      linkedDomainResult: linkedDomainResult)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            
            if objectToBeMapped is PresentationDefinition {
                return expectedVerifiedIdRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                return expectedRootOfTrust
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Act / Assert
        XCTAssertThrowsError(try mockMapper.map(presentationRequest)) { error in
            // Assert
            XCTAssert(error is PresentationRequestMappingError)
            XCTAssertEqual(error as? PresentationRequestMappingError, .callbackURLMalformed("//|\\"))
        }
    }
    
    func testMap_WithNoStatePresent_ThrowError() throws {
        // Arrange
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: false,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                              constraintOperator: .ALL))
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: [RequestedVPToken(presentationDefinition: mockPresentationDefinition)])
        let mockRegistration = RegistrationClaims(clientName: nil,
                                                  clientPurpose: nil,
                                                  logoURI: nil,
                                                  subjectIdentifierTypesSupported: nil,
                                                  vpFormats: nil)
        let token = createPresentationRequestToken(requestedClaims: mockRequestClaims,
                                                   registration: mockRegistration,
                                                   state: nil)
        
        let expectedRootOfTrust = RootOfTrust(verified: false, source: "")
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let presentationRequest = PresentationRequest(from: token,
                                                      linkedDomainResult: linkedDomainResult)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            
            if objectToBeMapped is PresentationDefinition {
                return expectedVerifiedIdRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                return expectedRootOfTrust
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Act / Assert
        XCTAssertThrowsError(try mockMapper.map(presentationRequest)) { error in
            // Assert
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: "state", in: "PresentationRequest"))
        }
    }
    
    func testMap_WithClientNamePresent_ReturnVerifiedIdRequestContent() throws {
        // Arrange
        let mockRequesterName = "mockRequesterName235"
        let expectedStyle = OpenIdVerifierStyle(name: mockRequesterName, logo: nil)
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: false,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                                        constraintOperator: .ALL))
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: [RequestedVPToken(presentationDefinition: mockPresentationDefinition)])
        let mockRegistration = RegistrationClaims(clientName: mockRequesterName,
                                                  clientPurpose: nil,
                                                  logoURI: nil,
                                                  subjectIdentifierTypesSupported: nil,
                                                  vpFormats: nil)
        let token = createPresentationRequestToken(requestedClaims: mockRequestClaims, registration: mockRegistration)
        
        let expectedRootOfTrust = RootOfTrust(verified: false, source: "")
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let presentationRequest = PresentationRequest(from: token,
                                                      linkedDomainResult: linkedDomainResult)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            
            if objectToBeMapped is PresentationDefinition {
                return expectedVerifiedIdRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                return expectedRootOfTrust
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mockMapper.map(presentationRequest)
        
        // Act
        XCTAssertIdentical(actualResult.requirement as AnyObject, expectedVerifiedIdRequirement as AnyObject)
        XCTAssertEqual(actualResult.rootOfTrust, expectedRootOfTrust)
        XCTAssertEqual(actualResult.style as? OpenIdVerifierStyle, expectedStyle)
        XCTAssertEqual(actualResult.callbackUrl.absoluteString, "https://test.com")
        XCTAssertEqual(actualResult.requestState, "mockState")
        XCTAssertNil(actualResult.injectedIdToken)
    }
    
    func testMap_WithLogoPresent_ReturnVerifiedIdRequestContent() throws {
        // Arrange
        let mockRequesterName = "mockRequesterName235"
        let mockLogo = VerifiedIdLogo(url: URL(string: "https://test.com"), altText: nil)
        let expectedStyle = OpenIdVerifierStyle(name: mockRequesterName, logo: mockLogo)
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: false,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                              constraintOperator: .ALL))
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: [RequestedVPToken(presentationDefinition: mockPresentationDefinition)])
        let mockRegistration = RegistrationClaims(clientName: mockRequesterName,
                                                  clientPurpose: nil,
                                                  logoURI: "https://test.com",
                                                  subjectIdentifierTypesSupported: nil,
                                                  vpFormats: nil)
        let token = createPresentationRequestToken(requestedClaims: mockRequestClaims, registration: mockRegistration)
        
        let expectedRootOfTrust = RootOfTrust(verified: false, source: "")
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let presentationRequest = PresentationRequest(from: token,
                                                      linkedDomainResult: linkedDomainResult)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            
            if objectToBeMapped is PresentationDefinition {
                return expectedVerifiedIdRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                return expectedRootOfTrust
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mockMapper.map(presentationRequest)
        
        // Act
        XCTAssertIdentical(actualResult.requirement as AnyObject, expectedVerifiedIdRequirement as AnyObject)
        XCTAssertEqual(actualResult.rootOfTrust, expectedRootOfTrust)
        XCTAssertEqual(actualResult.style as? OpenIdVerifierStyle, expectedStyle)
        XCTAssertEqual(actualResult.callbackUrl.absoluteString, "https://test.com")
        XCTAssertEqual(actualResult.requestState, "mockState")
        XCTAssertNil(actualResult.injectedIdToken)
    }
    
    func testMap_WithIdTokenHintWithoutPin_ReturnVerifiedIdRequestContentWithInjectedIdToken() throws {
        // Arrange
        let mockRequesterName = "mockRequesterName235"
        let expectedStyle = OpenIdVerifierStyle(name: mockRequesterName, logo: nil)
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: false,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                                        constraintOperator: .ALL))
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: [RequestedVPToken(presentationDefinition: mockPresentationDefinition)])
        let mockRegistration = RegistrationClaims(clientName: mockRequesterName,
                                                  clientPurpose: nil,
                                                  logoURI: nil,
                                                  subjectIdentifierTypesSupported: nil,
                                                  vpFormats: nil)
        let token = createPresentationRequestToken(requestedClaims: mockRequestClaims,
                                                   registration: mockRegistration,
                                                   idTokenHint: "mock idToken hint")
        
        let expectedRootOfTrust = RootOfTrust(verified: false, source: "")
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let presentationRequest = PresentationRequest(from: token,
                                                      linkedDomainResult: linkedDomainResult)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            
            if objectToBeMapped is PresentationDefinition {
                return expectedVerifiedIdRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                return expectedRootOfTrust
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mockMapper.map(presentationRequest)
        
        // Act
        XCTAssertIdentical(actualResult.requirement as AnyObject, expectedVerifiedIdRequirement as AnyObject)
        XCTAssertEqual(actualResult.rootOfTrust, expectedRootOfTrust)
        XCTAssertEqual(actualResult.style as? OpenIdVerifierStyle, expectedStyle)
        XCTAssertEqual(actualResult.callbackUrl.absoluteString, "https://test.com")
        XCTAssertEqual(actualResult.requestState, "mockState")
        XCTAssertEqual(actualResult.injectedIdToken?.rawToken, "mock idToken hint")
        XCTAssertNil(actualResult.injectedIdToken?.pin)
    }
    
    func testMap_WithIdTokenHintWithPin_ReturnVerifiedIdRequestContentWithInjectedIdToken() throws {
        // Arrange
        let mockRequesterName = "mockRequesterName235"
        let expectedPinRequirement = PinRequirement(required: true,
                                                    length: 4,
                                                    type: "mock pin type",
                                                    salt: "mock salt")
        let expectedStyle = OpenIdVerifierStyle(name: mockRequesterName, logo: nil)
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: false,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                                        constraintOperator: .ALL))
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: [RequestedVPToken(presentationDefinition: mockPresentationDefinition)])
        let mockRegistration = RegistrationClaims(clientName: mockRequesterName,
                                                  clientPurpose: nil,
                                                  logoURI: nil,
                                                  subjectIdentifierTypesSupported: nil,
                                                  vpFormats: nil)
        let pinDescriptor = PinDescriptor(type: "mock pin type",
                                          length: 4,
                                          hash: "mock hash",
                                          salt: "mock salt",
                                          iterations: nil,
                                          alg: nil)
        let token = createPresentationRequestToken(requestedClaims: mockRequestClaims,
                                                   registration: mockRegistration,
                                                   idTokenHint: "mock idToken hint",
                                                   pin: pinDescriptor)
        
        let expectedRootOfTrust = RootOfTrust(verified: false, source: "")
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let presentationRequest = PresentationRequest(from: token,
                                                      linkedDomainResult: linkedDomainResult)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            
            if objectToBeMapped is PresentationDefinition {
                return expectedVerifiedIdRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                return expectedRootOfTrust
            }
            
            if objectToBeMapped is PinDescriptor {
                return expectedPinRequirement
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mockMapper.map(presentationRequest)
        
        // Act
        XCTAssertIdentical(actualResult.requirement as AnyObject, expectedVerifiedIdRequirement as AnyObject)
        XCTAssertEqual(actualResult.rootOfTrust, expectedRootOfTrust)
        XCTAssertEqual(actualResult.style as? OpenIdVerifierStyle, expectedStyle)
        XCTAssertEqual(actualResult.callbackUrl.absoluteString, "https://test.com")
        XCTAssertEqual(actualResult.requestState, "mockState")
        XCTAssertEqual(actualResult.injectedIdToken?.rawToken, "mock idToken hint")
        XCTAssertIdentical(actualResult.injectedIdToken?.pin as AnyObject, expectedPinRequirement as AnyObject)
    }
    
    private func createPresentationRequestToken(requestedClaims: RequestedClaims? = nil,
                                                registration: RegistrationClaims? = nil,
                                                state: String? = "mockState",
                                                callbackUrl: String? = "https://test.com",
                                                idTokenHint: String? = nil,
                                                pin: PinDescriptor? = nil) -> PresentationRequestToken {
        let presentationRequestTokenClaims = PresentationRequestClaims(jti: nil,
                                                                       clientID: nil,
                                                                       redirectURI: callbackUrl,
                                                                       responseMode: nil,
                                                                       responseType: nil,
                                                                       claims: requestedClaims,
                                                                       state: state,
                                                                       nonce: nil,
                                                                       scope: nil,
                                                                       prompt: nil,
                                                                       registration: registration,
                                                                       idTokenHint: idTokenHint,
                                                                       iat: nil,
                                                                       exp: nil,
                                                                       pin: pin)
        
        return PresentationRequestToken(headers: Header(), content: presentationRequestTokenClaims)!
    }
}
