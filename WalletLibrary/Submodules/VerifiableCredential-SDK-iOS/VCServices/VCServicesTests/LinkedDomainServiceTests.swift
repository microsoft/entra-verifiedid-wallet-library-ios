/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities

@testable import VCServices

class LinkedDomainServiceTests: XCTestCase {
    
    var service: LinkedDomainService!
    let mockDomainUrl = "testDomain.com"
    
    override func setUpWithError() throws {
        
        service = setUpService()
        
        MockDiscoveryApiCalls.wasGetCalled = false
        MockWellKnownConfigDocumentApiCalls.wasGetCalled = false
        MockDomainLinkageCredentialValidator.wasValidateCalled = false
    }
    
    func testLinkedDomainVerifiedResult() {
        
        let expec = self.expectation(description: "Fire")
        service.validateLinkedDomain(from: validDid).done {
            result in
            print(result)
            XCTAssertEqual(result, LinkedDomainResult.linkedDomainVerified(domainUrl: self.mockDomainUrl))
            expec.fulfill()
        }.catch { error in
            print(error)
            XCTFail()
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 5)
    }
    
    func testLinkedDomainMissingResult() {
        let expec = self.expectation(description: "Fire")
        
        let service = setUpService(serviceEndpointType: "WrongServiceType")
        
        service.validateLinkedDomain(from: validDid).done {
            result in
            print(result)
            XCTAssertEqual(result, LinkedDomainResult.linkedDomainMissing)
            expec.fulfill()
        }.catch { error in
            print(error)
            XCTFail()
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 5)
    }
    
    func testLinkedDomainUnverifiedResult() {
        let expec = self.expectation(description: "Fire")
        
        let service = setUpService(isValid: false)
        
        service.validateLinkedDomain(from: validDid).done {
            result in
            print(result)
            XCTAssertEqual(result, LinkedDomainResult.linkedDomainUnverified(domainUrl: self.mockDomainUrl))
            expec.fulfill()
        }.catch { error in
            print(error)
            XCTFail()
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 5)
    }
    
    private func setUpService(serviceEndpointType: String = ServicesConstants.LINKED_DOMAINS_SERVICE_ENDPOINT_TYPE,
                              isValid: Bool = true) -> LinkedDomainService {
        
        let endpoint = IdentifierDocumentServiceEndpoint(origins: [mockDomainUrl])
        
        let serviceEndpointDescriptor = IdentifierDocumentServiceEndpointDescriptor(id: "testServiceEndpoint",
                                                                type: serviceEndpointType,
                                                                serviceEndpoint: endpoint)
        
        let document = IdentifierDocument(service: [serviceEndpointDescriptor],
                                          verificationMethod: [],
                                          authentication: [],
                                          id: validDid)
        
        let discoveryApiCalls = MockDiscoveryApiCalls(resolveSuccessfully: true,
                                                      withIdentifierDocument: document)
        let wellKnownApiCalls = MockWellKnownConfigDocumentApiCalls(resolveSuccessfully: true)
        let validator = MockDomainLinkageCredentialValidator(isValid: isValid)
        
        return LinkedDomainService(didDocumentDiscoveryApiCalls: discoveryApiCalls,
                                      wellKnownDocumentApiCalls: wellKnownApiCalls,
                                      domainLinkageValidator: validator)
    }
    
    let validDid = "did:ion:EiD89iut8PMhRz5zSlPl_zkHgEfRBiA9zdXYwAdrk1_JYg:eyJkZWx0YSI6eyJwYXRjaGVzIjpbeyJhY3Rpb24iOiJyZXBsYWNlIiwiZG9jdW1lbnQiOnsicHVibGljX2tleXMiOlt7ImlkIjoic2lnX2FkODRkZjIzIiwiandrIjp7ImNydiI6InNlY3AyNTZrMSIsImt0eSI6IkVDIiwieCI6IllMM2xlNC12YlNsa2ZINnJoQWJlbEJXTDByVlBieVJYTGtIUmx3REFZOTQiLCJ5IjoiYWFDZG1idjF0R1htZU1QWUdUY0ZqLUFnc2d2c2RNLXlGR2tnVU1QX04tVSJ9LCJwdXJwb3NlIjpbImF1dGgiLCJnZW5lcmFsIl0sInR5cGUiOiJFY2RzYVNlY3AyNTZrMVZlcmlmaWNhdGlvbktleTIwMTkifV0sInNlcnZpY2VfZW5kcG9pbnRzIjpbeyJlbmRwb2ludCI6eyJvcmlnaW5zIjpbImh0dHBzOi8vY29udG9zb3VuaXZlcnNpdHktZGlkZGVtby5henVyZXdlYnNpdGVzLm5ldC8iXX0sImlkIjoibGlua2VkZG9tYWlucyIsInR5cGUiOiJMaW5rZWREb21haW5zIn1dfX1dLCJ1cGRhdGVfY29tbWl0bWVudCI6IkVpQS1HSFJRVkcxV2F0bGprSVQxOGxvbWZXbTY0N2QwYmtlRmpCR2tMUjZMRXcifSwic3VmZml4X2RhdGEiOnsiZGVsdGFfaGFzaCI6IkVpQXBta0dpa2RiX3pHb1JrVU5vbmd0TXJlZS1xTjhPeEtsVmJvYUk5ZG9DdXciLCJyZWNvdmVyeV9jb21taXRtZW50IjoiRWlCb19vVkJYSEJmZGhfRFpkZjlqU3ZwQ1lnRmNkcXc3cDZFa1pPanU3bUREQSJ9fQ"
}
