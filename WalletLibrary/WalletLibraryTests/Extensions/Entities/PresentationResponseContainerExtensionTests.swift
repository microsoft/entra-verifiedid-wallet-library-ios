/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationResponseContainerExtensionTests: XCTestCase {
    
    enum MockError: Error {
        case expectedInvalidRequirement
        case secondExpectedInvalidRequirement
        case thirdExpectedInvalidRequirement
    }
    
    private let mockVerifiableCredentialHelper = MockVerifiableCredentialHelper()
    
    func testInit_WithInvalidOpenIdRawRequest_ThrowsError() throws {
        
        // Arrange
        let mockRawRequest = MockOpenIdRawRequest(raw: nil)
        
        // Act
        XCTAssertThrowsError(try PresentationResponseContainer(rawRequest: mockRawRequest)) { error in
            // Assert
            XCTAssert(error is PresentationResponseContainerError)
            XCTAssertEqual(error as? PresentationResponseContainerError,
                           PresentationResponseContainerError.unableToCastVCSDKPresentationRequestFromRawRequestOfType("MockOpenIdRawRequest"))
        }
    }
    
    func testInit_WithValidInput_ReturnPresentationResponseContainer() throws {
        // Arrange
        let rawPresentationRequest = createPresentationRequest()
        
        // Act
        let result = try PresentationResponseContainer(rawRequest: rawPresentationRequest)
        
        // Assert
        XCTAssertEqual(result.audienceDid, "expectedAudienceDid")
        XCTAssertEqual(result.audienceUrl, "expectedAudienceUrl")
        XCTAssertEqual(result.nonce, "expectedNonce")
        XCTAssert(result.requestVCMap.isEmpty)
    }
    
    func testAddRequirement_WithInvalidRequirementType_ThrowsError() async throws {
        // Arrange
        let mockPresentationRequest = createPresentationRequest()
        let invalidRequirement = MockRequirement(id: "mockRequirement")
        var presentationResponse = try PresentationResponseContainer(rawRequest: mockPresentationRequest)
        
        // Act
        XCTAssertThrowsError(try presentationResponse.add(requirement: invalidRequirement)) { error in
            // Assert
            XCTAssert(error is PresentationResponseContainerError)
            XCTAssertEqual(error as? PresentationResponseContainerError,
                           PresentationResponseContainerError.unsupportedRequirementOfType("MockRequirement"))
        }
    }
    
    func testAddRequirement_WithNoIdInVerifiedIdRequirement_ThrowsError() async throws {
        // Arrange
        let mockPresentationRequest = createPresentationRequest()
        var presentationResponse = try PresentationResponseContainer(rawRequest: mockPresentationRequest)
        
        let mockConstraint = MockConstraint(doesMatchResult: true)
        let verifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                          required: false,
                                                          types: ["mockType"],
                                                          purpose: nil,
                                                          issuanceOptions: [],
                                                          id: nil,
                                                          constraint: mockConstraint)
        
        // Act
        XCTAssertThrowsError(try presentationResponse.add(requirement: verifiedIdRequirement)) { error in
            // Assert
            XCTAssert(error is PresentationResponseContainerError)
            XCTAssertEqual(error as? PresentationResponseContainerError,
                           PresentationResponseContainerError.missingIdInVerifiedIdRequirement)
        }
    }
    
    func testAddRequirement_WithSelectedVerifiedIdTypeUnsupportedInVerifiedIdRequirement_AddsVCsToMap() async throws {
        // Arrange
        let mockPresentationRequest = createPresentationRequest()
        var presentationResponse = try PresentationResponseContainer(rawRequest: mockPresentationRequest)
        
        let mockConstraint = MockConstraint(doesMatchResult: true)
        let verifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                          required: false,
                                                          types: ["mockType"],
                                                          purpose: nil,
                                                          issuanceOptions: [],
                                                          id: "mockId",
                                                          constraint: mockConstraint)
        try verifiedIdRequirement.fulfill(with: MockVerifiedId(id: "mockId", issuedOn: Date())).get()
        
        // Act
        XCTAssertThrowsError(try presentationResponse.add(requirement: verifiedIdRequirement)) { error in
            // Assert
            XCTAssert(error is PresentationResponseContainerError)
            XCTAssertEqual(error as? PresentationResponseContainerError,
                           PresentationResponseContainerError.unableToCastVerifableCredentialFromVerifiedId)
        }
    }
    
    func testAddRequirement_WithVerifiedIdRequirement_AddsVCToMap() async throws {
        // Arrange
        let mockPresentationRequest = createPresentationRequest()
        var presentationResponse = try PresentationResponseContainer(rawRequest: mockPresentationRequest)
        
        let mockConstraint = MockConstraint(doesMatchResult: true)
        let verifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                          required: false,
                                                          types: ["mockType"],
                                                          purpose: nil,
                                                          issuanceOptions: [],
                                                          id: "mockId",
                                                          constraint: mockConstraint)
        let mockVC = mockVerifiableCredentialHelper.createMockVerifiableCredential()
        try verifiedIdRequirement.fulfill(with: mockVC).get()
        
        // Act / Assert
        XCTAssertNoThrow(try presentationResponse.add(requirement: verifiedIdRequirement))
        XCTAssertEqual(presentationResponse.requestVCMap.count, 1)
        XCTAssertEqual(try presentationResponse.requestVCMap.first?.vc.serialize(),
                       try mockVC.raw.serialize())
        XCTAssertEqual(presentationResponse.requestVCMap.first?.inputDescriptorId, verifiedIdRequirement.id)
    }
    
    func testAddRequirement_WithMultipleVerifiedIdRequirements_AddsVCsToMap() async throws {
        // Arrange
        let mockPresentationRequest = createPresentationRequest()
        var presentationResponse = try PresentationResponseContainer(rawRequest: mockPresentationRequest)
        
        let mockConstraint = MockConstraint(doesMatchResult: true)
        let verifiedIdRequirement1 = VerifiedIdRequirement(encrypted: false,
                                                          required: false,
                                                          types: ["mockType1"],
                                                          purpose: nil,
                                                          issuanceOptions: [],
                                                          id: "mockId1",
                                                          constraint: mockConstraint)
        let verifiedIdRequirement2 = VerifiedIdRequirement(encrypted: false,
                                                           required: false,
                                                           types: ["mockType2"],
                                                           purpose: nil,
                                                           issuanceOptions: [],
                                                           id: "mockId2",
                                                           constraint: mockConstraint)
        let mockVC1 = mockVerifiableCredentialHelper.createMockVerifiableCredential(expectedTypes: ["mockType1"])
        let mockVC2 = mockVerifiableCredentialHelper.createMockVerifiableCredential(expectedTypes: ["mockType2"])
        try verifiedIdRequirement1.fulfill(with: mockVC1).get()
        try verifiedIdRequirement2.fulfill(with: mockVC2).get()
        let groupRequirement = GroupRequirement(required: true,
                                                requirements: [verifiedIdRequirement1, verifiedIdRequirement2],
                                                requirementOperator: .ALL)
        
        // Act / Assert
        XCTAssertNoThrow(try presentationResponse.add(requirement: groupRequirement))
        XCTAssertEqual(presentationResponse.requestVCMap.count, 2)
        XCTAssertEqual(try presentationResponse.requestVCMap.first?.vc.serialize(),
                       try mockVC1.raw.serialize())
        XCTAssertEqual(presentationResponse.requestVCMap.first?.inputDescriptorId, verifiedIdRequirement1.id)
        XCTAssertEqual(try presentationResponse.requestVCMap[1].vc.serialize(),
                       try mockVC2.raw.serialize())
        XCTAssertEqual(presentationResponse.requestVCMap[1].inputDescriptorId, verifiedIdRequirement2.id)
    }
    
    private func createPresentationRequest() -> PresentationRequest {
        let mockClaims = PresentationRequestClaims(jti: "",
                                                   clientID: "expectedAudienceDid",
                                                   redirectURI: "expectedAudienceUrl",
                                                   responseMode: "",
                                                   responseType: "",
                                                   claims: nil,
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
