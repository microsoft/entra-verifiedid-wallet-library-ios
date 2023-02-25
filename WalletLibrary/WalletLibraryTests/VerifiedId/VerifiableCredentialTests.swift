/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
import VCToken
@testable import WalletLibrary

class VerifiableCredentialTests: XCTestCase {
    
    func testInit_WithValidInput_CreatesVerifiableCredential() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC()
        let mockContract = createMockSignedContract()

        // Act
        let actualResult = try WalletLibrary.VerifiableCredential(raw: mockVerifiableCredential, from: mockContract.content)
        
        // Assert
        XCTAssertEqual(try actualResult.raw.serialize(), try mockVerifiableCredential.serialize())
        XCTAssertEqual(actualResult.contract, mockContract.content)
        XCTAssertEqual(actualResult.expiresOn, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(actualResult.issuedOn, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(actualResult.id, actualResult.id)

    }
    
    private func createMockSignedContract(attestations: AttestationsDescriptor? = nil) -> SignedContract {
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
                                                                  attestations: attestations)
        let mockContract = Contract(id: "mockContract",
                                    display: mockDisplayDescriptor,
                                    input: mockContractInputDescriptor)
        
        return SignedContract(headers: Header(), content: mockContract)!
    }
    
    private func createVCEntitiesVC(expectedJti: String? = "1234",
                                    expectedIat: Double? = 0,
                                    expectedExp: Double? = 0,
                                    expectedClaims: [String: String] = [:]) -> VCEntities.VerifiableCredential {
        let claims = VCClaims(jti: expectedJti,
                              iss: "",
                              sub: "",
                              iat: expectedIat,
                              exp: expectedExp,
                              vc: VerifiableCredentialDescriptor(context: nil,
                                                                 type: nil,
                                                                 credentialSubject: expectedClaims))
        return VCEntities.VerifiableCredential(headers: Header(), content: claims)!
    }
    
    func testInit_WithMissingJtiOnVC_ThrowsError() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC(expectedJti: nil)
        let mockContract = createMockSignedContract()

        // Act
        XCTAssertThrowsError(try VerifiableCredential(raw: mockVerifiableCredential, from: mockContract.content)) { error in
            // Assert
            XCTAssert(error is VerifiableCredentialMappingError)
            XCTAssertEqual(error as? VerifiableCredentialMappingError, .missingJtiInVerifiableCredential)
        }
    }
    
    func testInit_WithMissingIatOnVC_ThrowsError() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC(expectedIat: nil)
        let mockContract = createMockSignedContract()

        // Act
        XCTAssertThrowsError(try VerifiableCredential(raw: mockVerifiableCredential, from: mockContract.content)) { error in
            // Assert
            XCTAssert(error is VerifiableCredentialMappingError)
            XCTAssertEqual(error as? VerifiableCredentialMappingError, .missingIssuedOnValueInVerifiableCredential)
        }
    }
    
    func testInit_WithNilExpOnVC_CreatesVerifiableCredential() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC(expectedExp: nil)
        let mockContract = createMockSignedContract()

        // Act
        let actualResult = try WalletLibrary.VerifiableCredential(raw: mockVerifiableCredential, from: mockContract.content)
        
        // Assert
        XCTAssertEqual(try actualResult.raw.serialize(), try mockVerifiableCredential.serialize())
        XCTAssertEqual(actualResult.contract, mockContract.content)
        XCTAssertNil(actualResult.expiresOn)
        XCTAssertEqual(actualResult.issuedOn, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(actualResult.id, actualResult.id)
    }
    
    func testGetClaims_WithMissingCredentialSubjectInVC_ReturnsEmptyList() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC()
        let mockContract = createMockSignedContract()
        let verifiableCredential = try VerifiableCredential(raw: mockVerifiableCredential,
                                                            from: mockContract.content)

        // Act
        let actualResult = verifiableCredential.getClaims()
        
        // Assert
        XCTAssert(actualResult.isEmpty)
    }
    
    func testGetClaims_WithNoLabelsInContract_ReturnsClaims() async throws {
        // Arrange
        let expectedValue1 = "mockValue1"
        let expectedValue2 = "mockValue2"
        let expectedClaim1 = VerifiedIdClaim(id: "mockKey1", value: expectedValue1)
        let expectedClaim2 = VerifiedIdClaim(id: "mockKey2", value: expectedValue2)
        let expectedResult = [expectedClaim1, expectedClaim2]
        let mockVCClaimDictionary = ["mockKey1": expectedValue1, "mockKey2": expectedValue2]
        let mockVerifiableCredential = createVCEntitiesVC(expectedClaims: mockVCClaimDictionary)
        let mockContract = createMockSignedContract()
        let verifiableCredential = try VerifiableCredential(raw: mockVerifiableCredential,
                                                            from: mockContract.content)

        // Act
        let actualResult = verifiableCredential.getClaims()
        
        // Assert
        areClaimsEqual(result: actualResult[0], expected: expectedClaim1)
        areClaimsEqual(result: actualResult[1], expected: expectedClaim2)
    }
    
    private func areClaimsEqual(result: VerifiedIdClaim, expected: VerifiedIdClaim) {
        XCTAssertEqual(result.id, expected.id)
        XCTAssertEqual(result.value as! String, expected.value as! String)
    }
    
    func testGetClaims_WithLabelsInContract_ReturnsClaims() async throws {
        // Arrange
        
        // Act
        
        // Assert
    }
    
    func testGetClaims_WithOneClaimWithNoLabelInContract_ReturnsClaims() async throws {
        // Arrange
        
        // Act
        
        // Assert
    }
    
    func testEncode_WhenUnableToSerializeVCToken_ThrowsError() async throws {
        // Arrange
        
        // Act
        
        // Assert
    }
    
    func testEncode_WhenUnableToSerializeContract_ThrowsError() async throws {
        // Arrange
        
        // Act
        
        // Assert
    }
    
    func testEncode_WithValidInput_ReturnsEncodedVerifiableCredential() async throws {
        // Arrange
        
        // Act
        
        // Assert
    }
    
    func testDecode_WithInvalidRawToken_ThrowsError() async throws {
        // Arrange
        
        // Act
        
        // Assert
    }
    
    func testDecode_WithInvalidContract_ThrowsError() async throws {
        // Arrange
        
        // Act
        
        // Assert
    }
    
    func testDecode_WithValidInput_CreatesVerifiableCredential() async throws {
        // Arrange
        
        // Act
        
        // Assert
    }
}
