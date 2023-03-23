/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class IssuanceRequestContentTests: XCTestCase {
    
    func testAddInjectedIdToken_WithIdTokenRequirementAndNoPin_AddIdTokenToRequirement() async throws {
        
        // Arrange
        let idTokenRequirement = createIdTokenRequirement()
        var issuanceRequestContent = IssuanceRequestContent(style: Manifest2022IssuerStyle(name: "mockIssuerName"),
                                                            verifiedIdStyle: MockVerifiedIdStyle(),
                                                            requirement: idTokenRequirement,
                                                            rootOfTrust: RootOfTrust(verified: false, source: nil))
        let injectedIdToken = InjectedIdToken(rawToken: "mockRawToken", pin: nil)
        
        // Act
        issuanceRequestContent.addRequirement(from: injectedIdToken)
        
        // Assert
        XCTAssert(issuanceRequestContent.requirement is IdTokenRequirement)
        XCTAssertEqual((issuanceRequestContent.requirement as? IdTokenRequirement)?.idToken, injectedIdToken.rawToken)
        
    }
    
    func testAddInjectedIdToken_WithIdTokenRequirementWithInvalidConfigurationValue_DoesNothing() async throws {
        
        // Arrange
        let idTokenRequirement = createIdTokenRequirement(configuration: "https://invalidConfiguration.me")
        var issuanceRequestContent = IssuanceRequestContent(style: Manifest2022IssuerStyle(name: "mockIssuerName"),
                                                            verifiedIdStyle: MockVerifiedIdStyle(),
                                                            requirement: idTokenRequirement,
                                                            rootOfTrust: RootOfTrust(verified: false, source: nil))
        let injectedIdToken = InjectedIdToken(rawToken: "mockRawToken", pin: nil)
        
        // Act
        issuanceRequestContent.addRequirement(from: injectedIdToken)
        
        // Assert
        XCTAssert(issuanceRequestContent.requirement is IdTokenRequirement)
        XCTAssertNil((issuanceRequestContent.requirement as? IdTokenRequirement)?.idToken)
    }
    
    func testAddInjectedIdToken_WithIdTokenRequirementAndPin_CreatesGroupRequirement() async throws {
        
        // Arrange
        let idTokenRequirement = createIdTokenRequirement()
        var issuanceRequestContent = IssuanceRequestContent(style: Manifest2022IssuerStyle(name: "mockIssuerName"),
                                                            verifiedIdStyle: MockVerifiedIdStyle(),
                                                            requirement: idTokenRequirement,
                                                            rootOfTrust: RootOfTrust(verified: false, source: nil))
        let pinRequirement = PinRequirement(required: false,
                                            length: 4,
                                            type: "numeric",
                                            salt: nil)
        let injectedIdToken = InjectedIdToken(rawToken: "mockRawToken", pin: pinRequirement)
        
        // Act
        issuanceRequestContent.addRequirement(from: injectedIdToken)
        
        // Assert
        XCTAssert(issuanceRequestContent.requirement is GroupRequirement)
        XCTAssertEqual((issuanceRequestContent.requirement as? GroupRequirement)?.requirements.count, 2)
        XCTAssertIdentical((issuanceRequestContent.requirement as? GroupRequirement)?.requirements.first as AnyObject,
                           idTokenRequirement as AnyObject)
        XCTAssertEqual(((issuanceRequestContent.requirement as? GroupRequirement)?.requirements.first as? IdTokenRequirement)?.idToken,
                       injectedIdToken.rawToken)
        XCTAssertIdentical((issuanceRequestContent.requirement as? GroupRequirement)?.requirements[1] as AnyObject,
                           pinRequirement as AnyObject)
    }
    
    func testAddInjectedIdToken_WithGroupRequirementAndNoPin_AddsIdTokenRequirement() async throws {
        
        // Arrange
        let mockRequirement = MockRequirement(id: "mockRequirement")
        let idTokenRequirement = createIdTokenRequirement()
        let groupRequirement = GroupRequirement(required: false,
                                                requirements: [mockRequirement, idTokenRequirement],
                                                requirementOperator: .ALL)
        var issuanceRequestContent = IssuanceRequestContent(style: Manifest2022IssuerStyle(name: "mockIssuerName"),
                                                            verifiedIdStyle: MockVerifiedIdStyle(),
                                                            requirement: groupRequirement,
                                                            rootOfTrust: RootOfTrust(verified: false, source: nil))
        let injectedIdToken = InjectedIdToken(rawToken: "mockRawToken", pin: nil)
        
        // Act
        issuanceRequestContent.addRequirement(from: injectedIdToken)
        
        // Assert
        XCTAssert(issuanceRequestContent.requirement is GroupRequirement)
        XCTAssertEqual((issuanceRequestContent.requirement as? GroupRequirement)?.requirements.count, 2)
        XCTAssertEqual((issuanceRequestContent.requirement as? GroupRequirement)?.requirements.first as? MockRequirement,
                       mockRequirement)
        XCTAssertIdentical((issuanceRequestContent.requirement as? GroupRequirement)?.requirements[1] as AnyObject,
                           idTokenRequirement as AnyObject)
        XCTAssertEqual(((issuanceRequestContent.requirement as? GroupRequirement)?.requirements[1] as? IdTokenRequirement)?.idToken,
                       injectedIdToken.rawToken)
    }
    
    func testAddInjectedIdToken_WithGroupRequirementAndPin_AddsIdTokenAndPinRequirement() async throws {
        
        // Arrange
        let mockRequirement = MockRequirement(id: "mockRequirement")
        let idTokenRequirement = createIdTokenRequirement()
        let groupRequirement = GroupRequirement(required: false,
                                                requirements: [mockRequirement, idTokenRequirement],
                                                requirementOperator: .ALL)
        var issuanceRequestContent = IssuanceRequestContent(style: Manifest2022IssuerStyle(name: "mockIssuerName"),
                                                            verifiedIdStyle: MockVerifiedIdStyle(),
                                                            requirement: groupRequirement,
                                                            rootOfTrust: RootOfTrust(verified: false, source: nil))
        let pinRequirement = PinRequirement(required: false,
                                            length: 4,
                                            type: "numeric",
                                            salt: nil)
        let injectedIdToken = InjectedIdToken(rawToken: "mockRawToken", pin: pinRequirement)
        
        // Act
        issuanceRequestContent.addRequirement(from: injectedIdToken)
        
        // Assert
        XCTAssert(issuanceRequestContent.requirement is GroupRequirement)
        XCTAssertEqual((issuanceRequestContent.requirement as? GroupRequirement)?.requirements.count, 3)
        XCTAssertEqual((issuanceRequestContent.requirement as? GroupRequirement)?.requirements.first as? MockRequirement,
                       mockRequirement)
        XCTAssertIdentical((issuanceRequestContent.requirement as? GroupRequirement)?.requirements[1] as AnyObject,
                           idTokenRequirement as AnyObject)
        XCTAssertEqual(((issuanceRequestContent.requirement as? GroupRequirement)?.requirements[1] as? IdTokenRequirement)?.idToken,
                       injectedIdToken.rawToken)
        XCTAssertIdentical((issuanceRequestContent.requirement as? GroupRequirement)?.requirements[2] as AnyObject,
                           pinRequirement as AnyObject)
    }
    
    private func createIdTokenRequirement(configuration: String = "https://self-issued.me") -> IdTokenRequirement {
        return IdTokenRequirement(encrypted: false,
                                  required: false,
                                  configuration: URL(string: configuration)!,
                                  clientId: "mockClientId",
                                  redirectUri: "mockRedirectUri",
                                  scope: nil)
    }
}
