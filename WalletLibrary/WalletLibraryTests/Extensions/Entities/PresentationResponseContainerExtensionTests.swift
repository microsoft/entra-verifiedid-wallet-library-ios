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
    
    func testAddRequirement_WithVerifiedIdRequirement_AddsVCToMap() async throws {
        // TODO
    }
    
    func testAddRequirement_WithMultipleVerifiedIdRequirements_AddsVCsToMap() async throws {
        // TODO
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
