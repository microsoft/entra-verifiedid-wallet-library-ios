/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class LinkedDomainServiceTests: XCTestCase {
    
    var service: LinkedDomainService!
    let mockDomainUrl = "testDomain.com"
    
    override func setUpWithError() throws {
        service = setUpService()
        MockDiscoveryApiCalls.wasGetCalled = false
        MockWellKnownConfigDocumentApiCalls.wasGetCalled = false
        MockDomainLinkageCredentialValidator.wasValidateCalled = false
    }
    
    func testLinkedDomainVerifiedResult() async throws {
        // Arrange
        let document = createIdentifierDocument(serviceEndpointType: ServicesConstants.LINKED_DOMAINS_SERVICE_ENDPOINT_TYPE)
        
        // Act
        let result = try await service.validateLinkedDomain(from: document)
        
        // Assert
        XCTAssertEqual(result, LinkedDomainResult.linkedDomainVerified(domainUrl: self.mockDomainUrl))
    }
    
    func testLinkedDomainMissingResult() async throws {
        // Arrange
        let document = createIdentifierDocument(serviceEndpointType: "Wrong Service Type")
        
        // Act
        let result = try await service.validateLinkedDomain(from: document)
        
        // Assert
        XCTAssertEqual(result, LinkedDomainResult.linkedDomainMissing)
    }
    
    func testLinkedDomainUnverifiedResult() async throws {
        // Arrange
        let document = createIdentifierDocument(serviceEndpointType: ServicesConstants.LINKED_DOMAINS_SERVICE_ENDPOINT_TYPE)
        let service = setUpService(isLinkageCredentialValid: false)
        
        // Act
        let result = try await service.validateLinkedDomain(from: document)
        
        // Assert
        XCTAssertEqual(result, LinkedDomainResult.linkedDomainUnverified(domainUrl: self.mockDomainUrl))
    }
    
    private func setUpService(isLinkageCredentialValid: Bool = true) -> LinkedDomainService {
        let wellKnownApiCalls = MockWellKnownConfigDocumentApiCalls(resolveSuccessfully: true)
        let validator = MockDomainLinkageCredentialValidator(isValid: isLinkageCredentialValid)
        
        return LinkedDomainService(wellKnownDocumentApiCalls: wellKnownApiCalls,
                                   domainLinkageValidator: validator)
    }
    
    private func createIdentifierDocument(serviceEndpointType: String) -> IdentifierDocument {
        let endpoint = IdentifierDocumentServiceEndpoint(origins: [mockDomainUrl])
        
        let serviceEndpointDescriptor = IdentifierDocumentServiceEndpointDescriptor(id: "testServiceEndpoint",
                                                                                    type: serviceEndpointType,
                                                                                    serviceEndpoint: endpoint)
        
        return IdentifierDocument(service: [serviceEndpointDescriptor],
                                  verificationMethod: [],
                                  authentication: [],
                                  id: "did:test:1234")
    }
}
