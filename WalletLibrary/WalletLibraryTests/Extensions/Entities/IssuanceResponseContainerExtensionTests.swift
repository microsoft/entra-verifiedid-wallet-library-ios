/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
import VCToken
@testable import WalletLibrary

class IssuanceResponseContainerExtensionTests: XCTestCase {
    
    enum MockError: Error {
        case expectedInvalidRequirement
        case secondExpectedInvalidRequirement
        case thirdExpectedInvalidRequirement
    }
    
    func testInit_WithInvalidRawManifest_ThrowsError() throws {
        
        // Arrange
        let mockRawManifest = MockRawManifest(id: "")
        let mockInput = MockInput(mockData: "")
        
        // Act
        XCTAssertThrowsError(try IssuanceResponseContainer(from: mockRawManifest, input: mockInput)) { error in
            // Assert
            XCTAssert(error is IssuanceResponseContainerError)
            XCTAssertEqual(error as? IssuanceResponseContainerError,
                           .unableToCastVCSDKIssuanceRequestFromRawManifestOfType("MockRawManifest"))
        }
    }
    
    func testInit_WithInvalidInput_ThrowsError() throws {
        
        // Arrange
        let issuanceRequest = createMockIssuanceRequest()
        let mockInput = MockInput(mockData: "")
        
        // Act
        XCTAssertThrowsError(try IssuanceResponseContainer(from: issuanceRequest, input: mockInput)) { error in
            // Assert
            XCTAssert(error is IssuanceResponseContainerError)
            XCTAssertEqual(error as? IssuanceResponseContainerError,
                           .unableToCastVerifiedIdRequestURLFromInputOfType("MockInput"))
            
        }
    }
    
    func testInit_WithValidInput_ReturnIssuanceResponseContainer() throws {
        // Arrange
        let issuanceRequest = createMockIssuanceRequest()
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://test.com")!)
        
        // Act
        let container = try IssuanceResponseContainer(from: issuanceRequest, input: mockInput)
        
        // Assert
        XCTAssertEqual(container.contract, issuanceRequest.content)
        XCTAssertEqual(container.contractUri, mockInput.url.absoluteString)
    }
    
    func testAddRequirement_WithIdTokenRequirement_UpdatesMap() async throws {
        // Arrange
        let issuanceRequest = createMockIssuanceRequest()
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://test.com")!)
        var container = try IssuanceResponseContainer(from: issuanceRequest, input: mockInput)
        
        let requirement = IdTokenRequirement(encrypted: false,
                                             required: true,
                                             configuration: URL(string: "https://configuration.com")!,
                                             clientId: "",
                                             redirectUri: "",
                                             scope: "")
        requirement.fulfill(with: "mock token")
        
        // Act
        try container.add(requirement: requirement)
        
        // Assert
        XCTAssertEqual(container.requestedIdTokenMap, [requirement.configuration.absoluteString: requirement.idToken])
        XCTAssertNil(container.issuanceIdToken)
        XCTAssert(container.requestedAccessTokenMap.isEmpty)
        XCTAssert(container.requestedSelfAttestedClaimMap.isEmpty)
        XCTAssert(container.requestVCMap.isEmpty)
        XCTAssertNil(container.issuancePin)
    }
    
    func testAddRequirement_WithIdTokenHintRequirement_UpdateIdTokenHintValue() async throws {
        // Arrange
        let issuanceRequest = createMockIssuanceRequest()
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://test.com")!)
        var container = try IssuanceResponseContainer(from: issuanceRequest, input: mockInput)
        
        let requirement = IdTokenRequirement(encrypted: false,
                                             required: true,
                                             configuration: URL(string: "https://self-issued.me")!,
                                             clientId: "",
                                             redirectUri: "",
                                             scope: "")
        requirement.fulfill(with: "mock token")
        
        // Act
        try container.add(requirement: requirement)
        
        // Assert
        XCTAssertNotNil(container.issuanceIdToken)
        XCTAssertEqual(container.issuanceIdToken, "mock token")
        XCTAssert(container.requestedIdTokenMap.isEmpty)
        XCTAssert(container.requestedAccessTokenMap.isEmpty)
        XCTAssert(container.requestedSelfAttestedClaimMap.isEmpty)
        XCTAssert(container.requestVCMap.isEmpty)
        XCTAssertNil(container.issuancePin)
    }
    
    func testAddRequirement_WithAccessTokenRequirement_UpdatesMap() async throws {
        // Arrange
        let issuanceRequest = createMockIssuanceRequest()
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://test.com")!)
        var container = try IssuanceResponseContainer(from: issuanceRequest, input: mockInput)
        
        let requirement = AccessTokenRequirement(encrypted: false,
                                                 required: true,
                                                 configuration: "mock configuration",
                                                 clientId: "",
                                                 resourceId: "",
                                                 scope: "")
        requirement.fulfill(with: "mock token")
        
        // Act
        try container.add(requirement: requirement)
        
        // Assert
        XCTAssertEqual(container.requestedAccessTokenMap, [requirement.configuration: requirement.accessToken])
        XCTAssert(container.requestedIdTokenMap.isEmpty)
        XCTAssert(container.requestedSelfAttestedClaimMap.isEmpty)
        XCTAssert(container.requestVCMap.isEmpty)
        XCTAssertNil(container.issuancePin)
    }
    
    func testAddRequirement_WithSelfAttestedRequirement_UpdatesMap() async throws {
        // Arrange
        let issuanceRequest = createMockIssuanceRequest()
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://test.com")!)
        var container = try IssuanceResponseContainer(from: issuanceRequest, input: mockInput)
        
        let requirement = SelfAttestedClaimRequirement(encrypted: false,
                                                       required: true,
                                                       claim: "mock claim")
        requirement.fulfill(with: "mock value")
        
        // Act
        try container.add(requirement: requirement)
        
        // Assert
        XCTAssertEqual(container.requestedSelfAttestedClaimMap, [requirement.claim: requirement.value])
        XCTAssert(container.requestedIdTokenMap.isEmpty)
        XCTAssert(container.requestedAccessTokenMap.isEmpty)
        XCTAssert(container.requestVCMap.isEmpty)
        XCTAssertNil(container.issuancePin)
    }
    
    func testAddRequirement_WithPinRequirement_UpdatesPin() async throws {
        // Arrange
        let issuanceRequest = createMockIssuanceRequest()
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://test.com")!)
        var container = try IssuanceResponseContainer(from: issuanceRequest, input: mockInput)
        
        let requirement = PinRequirement(required: false,
                                         length: 5,
                                         type: "",
                                         salt: "mock salt")
        requirement.fulfill(with: "mock value")
        
        // Act
        try container.add(requirement: requirement)
        
        // Assert
        XCTAssert(container.requestedSelfAttestedClaimMap.isEmpty)
        XCTAssert(container.requestedIdTokenMap.isEmpty)
        XCTAssert(container.requestedAccessTokenMap.isEmpty)
        XCTAssert(container.requestVCMap.isEmpty)
        XCTAssertEqual(container.issuancePin, IssuancePin(from: requirement.pin!, withSalt: requirement.salt))
    }
    
    func testAddRequirement_WithVerifiedIdRequirement_UpdatesMap() async throws {
        // TODO
    }
    
    func testAddRequirement_WithGroupRequirementWithTwoSelfAttestedRequirements_UpdatesMap() async throws {
        // Arrange
        let issuanceRequest = createMockIssuanceRequest()
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://test.com")!)
        var container = try IssuanceResponseContainer(from: issuanceRequest, input: mockInput)
        
        let requirement = SelfAttestedClaimRequirement(encrypted: false,
                                                       required: true,
                                                       claim: "mock claim")
        let secondRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                             required: true,
                                                             claim: "mock claim 2")
        requirement.fulfill(with: "mock value")
        secondRequirement.fulfill(with: "mock second value")
        
        let groupRequirement = GroupRequirement(required: false,
                                                requirements: [requirement, secondRequirement],
                                                requirementOperator: .ALL)
        
        // Act
        try container.add(requirement: groupRequirement)
        
        // Assert
        let expectedMap = [requirement.claim: requirement.value, secondRequirement.claim: secondRequirement.value]
        XCTAssertEqual(container.requestedSelfAttestedClaimMap, expectedMap)
        XCTAssert(container.requestedIdTokenMap.isEmpty)
        XCTAssert(container.requestedAccessTokenMap.isEmpty)
        XCTAssert(container.requestVCMap.isEmpty)
        XCTAssertNil(container.issuancePin)
    }
    
    func testAddRequirement_WithGroupRequirementWithMultipleRequirements_UpdatesMap() async throws {
        // Arrange
        let issuanceRequest = createMockIssuanceRequest()
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://test.com")!)
        var container = try IssuanceResponseContainer(from: issuanceRequest, input: mockInput)
        
        let requirement = SelfAttestedClaimRequirement(encrypted: false,
                                                       required: true,
                                                       claim: "mock claim")
        let accessTokenRequirement = AccessTokenRequirement(encrypted: false,
                                                            required: true,
                                                            configuration: "mock configuration",
                                                            clientId: "",
                                                            resourceId: "",
                                                            scope: "")
        let idTokenRequirement = IdTokenRequirement(encrypted: false,
                                                    required: true,
                                                    configuration: URL(string: "https://configuration.com")!,
                                                    clientId: "",
                                                    redirectUri: "",
                                                    scope: "")
        
        requirement.fulfill(with: "mock value")
        accessTokenRequirement.fulfill(with: "mock access token")
        idTokenRequirement.fulfill(with: "mock id token")
        
        let groupRequirement = GroupRequirement(required: false,
                                                requirements: [requirement, accessTokenRequirement, idTokenRequirement],
                                                requirementOperator: .ALL)
        
        // Act
        try container.add(requirement: groupRequirement)
        
        // Assert
        XCTAssertEqual(container.requestedSelfAttestedClaimMap, [requirement.claim: requirement.value])
        XCTAssertEqual(container.requestedAccessTokenMap, [accessTokenRequirement.configuration: accessTokenRequirement.accessToken])
        XCTAssertEqual(container.requestedIdTokenMap, [idTokenRequirement.configuration.absoluteString: idTokenRequirement.idToken])
        XCTAssert(container.requestVCMap.isEmpty)
        XCTAssertNil(container.issuancePin)
    }
    
    func testAddRequirement_WithUnsupportedRequirementType_ThrowsError() async throws {
        // Arrange
        let issuanceRequest = createMockIssuanceRequest()
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://test.com")!)
        var container = try IssuanceResponseContainer(from: issuanceRequest, input: mockInput)

        let mockRequirement = MockRequirement(id: "")
        
        // Act
        XCTAssertThrowsError(try container.add(requirement: mockRequirement)) { error in
            // Assert
            XCTAssert(error is IssuanceResponseContainerError)
            XCTAssertEqual(error as? IssuanceResponseContainerError, .unsupportedRequirementOfType("MockRequirement"))
        }
    }
    
    private func createMockIssuanceRequest() -> IssuanceRequest {
        let mockCardDisplay = CardDisplayDescriptor(title: "mock title",
                                                    issuedBy: "mock issuer",
                                                    backgroundColor: "mock background color",
                                                    textColor: "mock text color",
                                                    logo: nil,
                                                    cardDescription: "mock description")
        let mockConsentDisplay = ConsentDisplayDescriptor(title: nil,
                                                          instructions: "mock purpose")
        let mockDisplayDescriptor = DisplayDescriptor(id: nil,
                                                      locale: nil,
                                                      contract: nil,
                                                      card: mockCardDisplay,
                                                      consent: mockConsentDisplay,
                                                      claims: [:])
        let mockContractInputDescriptor = ContractInputDescriptor(credentialIssuer: "mock credential issuer",
                                                                  issuer: "mock issuer",
                                                                  attestations: nil)
        let mockContract = Contract(id: "mockContract",
                                    display: mockDisplayDescriptor,
                                    input: mockContractInputDescriptor)
        
        let mockSignedContract = SignedContract(headers: Header(), content: mockContract)!
        return IssuanceRequest(from: mockSignedContract, linkedDomainResult: .linkedDomainMissing)
    }
}
