/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
import VCToken
@testable import WalletLibrary

class VCTypeConstraintTests: XCTestCase {
    
    func testDoesMatch_WithUnsupportedVerifiedIdType_ReturnFalse() throws {
        // Arrange
        let constraint = VCTypeConstraint(type: "mockType")
        let unsupportedVerifiedId = MockVerifiedId(id: "mock verified id", issuedOn: Date())
        
        // Act
        let result = constraint.doesMatch(verifiedId: unsupportedVerifiedId)
        
        // Assert
        XCTAssertFalse(result)
    }
    
    func testDoesMatch_WhenVCContainsType_ReturnTrue() throws {
        // Arrange
        let constraint = VCTypeConstraint(type: "mockType")
        let mockRawVC = createVCEntitiesVC(expectedTypes: ["mockType"])
        let mockContract = createMockContract()
        let verifiableCredential = try VerifiableCredential(raw: mockRawVC, from: mockContract)
        
        // Act
        let result = constraint.doesMatch(verifiedId: verifiableCredential)
        
        // Assert
        XCTAssertTrue(result)
    }
    
    func testDoesMatch_WhenVCContainsMultipleTypes_ReturnTrue() throws {
        // Arrange
        let constraint = VCTypeConstraint(type: "mockType")
        let mockRawVC = createVCEntitiesVC(expectedTypes: ["mockType", "unmatchingType"])
        let mockContract = createMockContract()
        let verifiableCredential = try VerifiableCredential(raw: mockRawVC, from: mockContract)
        
        // Act
        let result = constraint.doesMatch(verifiedId: verifiableCredential)
        
        // Assert
        XCTAssertTrue(result)
    }
    
    func testDoesMatch_WhenVCDoesNotContainType_ReturnFalse() throws {
        // Arrange
        let constraint = VCTypeConstraint(type: "mockType")
        let mockRawVC = createVCEntitiesVC(expectedTypes: ["unmatchingType"])
        let mockContract = createMockContract()
        let verifiableCredential = try VerifiableCredential(raw: mockRawVC, from: mockContract)
        
        // Act
        let result = constraint.doesMatch(verifiedId: verifiableCredential)
        
        // Assert
        XCTAssertFalse(result)
    }
    
    private func createVCEntitiesVC(expectedTypes: [String]) -> VCEntities.VerifiableCredential {
        let claims = VCClaims(jti: "",
                              iss: "",
                              sub: "",
                              iat: 0,
                              exp: 0,
                              vc: VerifiableCredentialDescriptor(context: [],
                                                                 type: expectedTypes,
                                                                 credentialSubject: [:]))
        return VCEntities.VerifiableCredential(headers: Header(), content: claims)!
    }
    
    private func createMockContract() -> Contract {
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
        return Contract(id: "mockContract",
                        display: mockDisplayDescriptor,
                        input: mockContractInputDescriptor)
    }
}
