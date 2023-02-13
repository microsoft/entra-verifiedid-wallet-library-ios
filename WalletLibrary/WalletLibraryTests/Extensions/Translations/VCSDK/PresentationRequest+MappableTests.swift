/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
import VCToken
@testable import WalletLibrary

class PresentationRequestMappingTests: XCTestCase {
    
    enum ExpectedError: Error {
        case expectedToBeThrown
    }
    
    let mapper = Mapper()
    
    func testMap_WithNoPresentationDefinitionPresent_ThrowsError() throws {
        // Arrange
        let mockRequestClaims = RequestedClaims(vpToken: RequestedVPToken(presentationDefinition: nil))
        let token = createPresentationRequestToken(with: mockRequestClaims, and: nil)
        
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
        let mockRequestClaims = RequestedClaims(vpToken: RequestedVPToken(presentationDefinition: mockPresentationDefinition))
        let token = createPresentationRequestToken(with: mockRequestClaims, and: nil)
        
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
                                                              issuanceOptions: [])
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: RequestedVPToken(presentationDefinition: mockPresentationDefinition))
        let token = createPresentationRequestToken(with: mockRequestClaims, and: nil)
        
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
        
        // Assert
        XCTAssertThrowsError(try mockMapper.map(presentationRequest)) { error in
            // Assert
            print(error)
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, .expectedToBeThrown)
        }
    }
    
    func testMap_WithNoClientNamePresent_ReturnVerifiedIdRequestContent() throws {
        // Arrange
        let expectedStyle = OpenIdRequesterStyle(requester: "")
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                              required: false,
                                                              types: [],
                                                              purpose: nil,
                                                              issuanceOptions: [])
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: RequestedVPToken(presentationDefinition: mockPresentationDefinition))
        let mockRegistration = RegistrationClaims(clientName: nil,
                                            clientPurpose: nil,
                                            logoURI: nil,
                                            subjectIdentifierTypesSupported: nil,
                                            vpFormats: nil)
        let token = createPresentationRequestToken(with: mockRequestClaims, and: mockRegistration)
        
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
        XCTAssertEqual(actualResult.style as? OpenIdRequesterStyle, expectedStyle)
    }
    
    func testMap_WithClientNamePresent_ReturnVerifiedIdRequestContent() throws {
        // Arrange
        let mockRequesterName = "mockRequesterName235"
        let expectedStyle = OpenIdRequesterStyle(requester: mockRequesterName)
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                              required: false,
                                                              types: [],
                                                              purpose: nil,
                                                              issuanceOptions: [])
        let mockPresentationDefinition = PresentationDefinition(id: nil, inputDescriptors: nil, issuance: nil)
        let mockRequestClaims = RequestedClaims(vpToken: RequestedVPToken(presentationDefinition: mockPresentationDefinition))
        let mockRegistration = RegistrationClaims(clientName: mockRequesterName,
                                            clientPurpose: nil,
                                            logoURI: nil,
                                            subjectIdentifierTypesSupported: nil,
                                            vpFormats: nil)
        let token = createPresentationRequestToken(with: mockRequestClaims, and: mockRegistration)
        
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
        XCTAssertEqual(actualResult.style as? OpenIdRequesterStyle, expectedStyle)
    }
    
    private func createPresentationRequestToken(with requestedClaims: RequestedClaims?,
                                                and registration: RegistrationClaims?) -> PresentationRequestToken {
        let presentationRequestTokenClaims = PresentationRequestClaims(jti: nil,
                                                                       clientID: nil,
                                                                       redirectURI: nil,
                                                                       responseType: nil,
                                                                       responseMode: nil,
                                                                       claims: requestedClaims,
                                                                       state: nil,
                                                                       nonce: nil,
                                                                       scope: nil,
                                                                       prompt: nil,
                                                                       registration: registration,
                                                                       idTokenHint: nil,
                                                                       iat: nil,
                                                                       exp: nil)
        
        return PresentationRequestToken(headers: Header(), content: presentationRequestTokenClaims)!
    }
}
