/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
import VCToken
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
            XCTAssert(error is PresentationResponseError)
            XCTAssertEqual(error as? PresentationResponseError,
                           PresentationResponseError.unableToCastVCSDKPresentationRequestFromRawRequestOfType("MockOpenIdRawRequest"))
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
            XCTAssert(error is PresentationResponseError)
            XCTAssertEqual(error as? PresentationResponseError,
                           PresentationResponseError.unsupportedRequirementOfType("MockRequirement"))
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
            XCTAssert(error is PresentationResponseError)
            XCTAssertEqual(error as? PresentationResponseError,
                           PresentationResponseError.missingIdInVerifiedIdRequirement)
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
        verifiedIdRequirement.selectedVerifiedId = MockVerifiedId(id: "mockId", issuedOn: Date())
        
        // Act
        XCTAssertThrowsError(try presentationResponse.add(requirement: verifiedIdRequirement)) { error in
            // Assert
            XCTAssert(error is PresentationResponseError)
            XCTAssertEqual(error as? PresentationResponseError,
                           PresentationResponseError.unableToCastVerifableCredentialFromVerifiedId)
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
        let vc = mockVerifiableCredentialHelper.createMockVerifiableCredential()
        verifiedIdRequirement.selectedVerifiedId = vc
        
        // Act / Assert
        XCTAssertNoThrow(try presentationResponse.add(requirement: verifiedIdRequirement))
        XCTAssertEqual(presentationResponse.requestVCMap.count, 1)
        XCTAssertEqual(try presentationResponse.requestVCMap.first?.vc.serialize(),
                       try vc.raw.serialize())
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
        let vc1 = mockVerifiableCredentialHelper.createMockVerifiableCredential(expectedTypes: ["mockType1"])
        let vc2 = mockVerifiableCredentialHelper.createMockVerifiableCredential(expectedTypes: ["mockType2"])
        verifiedIdRequirement1.selectedVerifiedId = vc1
        verifiedIdRequirement2.selectedVerifiedId = vc2
        let groupRequirement = GroupRequirement(required: true,
                                                requirements: [verifiedIdRequirement1, verifiedIdRequirement2],
                                                requirementOperator: .ALL)
        
        // Act / Assert
        XCTAssertNoThrow(try presentationResponse.add(requirement: groupRequirement))
        XCTAssertEqual(presentationResponse.requestVCMap.count, 2)
        XCTAssertEqual(try presentationResponse.requestVCMap.first?.vc.serialize(),
                       try vc1.raw.serialize())
        XCTAssertEqual(presentationResponse.requestVCMap.first?.inputDescriptorId, verifiedIdRequirement1.id)
        XCTAssertEqual(try presentationResponse.requestVCMap[1].vc.serialize(),
                       try vc2.raw.serialize())
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
