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
        let actualResult = try WalletLibrary.VerifiableCredential(raw: mockVerifiableCredential, from: mockContract)
        
        // Assert
        XCTAssertEqual(try actualResult.raw.serialize(), try mockVerifiableCredential.serialize())
        XCTAssertEqual(actualResult.contract, mockContract)
        XCTAssertEqual(actualResult.expiresOn, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(actualResult.issuedOn, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(actualResult.id, actualResult.id)

    }
    
    func testInit_WithMissingJtiOnVC_ThrowsError() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC(expectedJti: nil)
        let mockContract = createMockSignedContract()

        // Act
        XCTAssertThrowsError(try VerifiableCredential(raw: mockVerifiableCredential, from: mockContract)) { error in
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
        XCTAssertThrowsError(try VerifiableCredential(raw: mockVerifiableCredential, from: mockContract)) { error in
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
        let actualResult = try WalletLibrary.VerifiableCredential(raw: mockVerifiableCredential, from: mockContract)
        
        // Assert
        XCTAssertEqual(try actualResult.raw.serialize(), try mockVerifiableCredential.serialize())
        XCTAssertEqual(actualResult.contract, mockContract)
        XCTAssertNil(actualResult.expiresOn)
        XCTAssertEqual(actualResult.issuedOn, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(actualResult.id, actualResult.id)
    }
    
    func testGetClaims_WithMissingCredentialSubjectInVC_ReturnsEmptyList() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC()
        let mockContract = createMockSignedContract()
        let verifiableCredential = try VerifiableCredential(raw: mockVerifiableCredential,
                                                            from: mockContract)

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
        let mockVCClaimDictionary = ["mockKey1": expectedValue1, "mockKey2": expectedValue2]
        let mockVerifiableCredential = createVCEntitiesVC(expectedClaims: mockVCClaimDictionary)
        let mockContract = createMockSignedContract()
        let verifiableCredential = try VerifiableCredential(raw: mockVerifiableCredential,
                                                            from: mockContract)

        // Act
        let actualResult = verifiableCredential.getClaims()
        
        // Assert
        XCTAssertEqual(actualResult.count, 2)
        XCTAssert(actualResult.contains {
            areClaimsEqual(result: $0, expected: expectedClaim1)
        })
        XCTAssert(actualResult.contains {
            areClaimsEqual(result: $0, expected: expectedClaim2)
        })
    }
    
    func testGetClaims_WithLabelsInContract_ReturnsClaims() async throws {
        // Arrange
        let expectedValue1 = "mockValue1"
        let expectedClaim1 = VerifiedIdClaim(id: "MockLabel1", value: expectedValue1)
        let mockVCClaimDictionary = ["mockKey1": expectedValue1]
        let mockVerifiableCredential = createVCEntitiesVC(expectedClaims: mockVCClaimDictionary)
        let expectedClaimLabel1 = ClaimDisplayDescriptor(type: "String",
                                                         label: "MockLabel1")
        let expectedClaimLabels = ["vc.credentialSubject.mockKey1": expectedClaimLabel1]
        let mockContract = createMockSignedContract(claims: expectedClaimLabels)
        let verifiableCredential = try VerifiableCredential(raw: mockVerifiableCredential,
                                                            from: mockContract)

        // Act
        let actualResult = verifiableCredential.getClaims()
        
        // Assert
        XCTAssertEqual(actualResult.count, 1)
        XCTAssert(actualResult.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "MockLabel1", value: expectedValue1))
        })
    }
    
    func testGetClaims_WithOneClaimWithNoLabelInContract_ReturnsClaims() async throws {
        // Arrange
        let expectedValue1 = "mockValue1"
        let expectedValue2 = "mockValue2"
        
        let mockVCClaimDictionary = ["mockKey1": expectedValue1, "mockKey2": expectedValue2]
        let mockVerifiableCredential = createVCEntitiesVC(expectedClaims: mockVCClaimDictionary)
        
        let expectedClaimLabel1 = ClaimDisplayDescriptor(type: "String", label: "MockLabel1")
        let expectedClaimLabels = ["vc.credentialSubject.mockKey1": expectedClaimLabel1]
        let mockContract = createMockSignedContract(claims: expectedClaimLabels)

        let verifiableCredential = try VerifiableCredential(raw: mockVerifiableCredential,
                                                            from: mockContract)

        // Act
        let actualResult = verifiableCredential.getClaims()
        
        // Assert
        XCTAssertEqual(actualResult.count, 2)
        XCTAssert(actualResult.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "MockLabel1", value: expectedValue1))
        })
        XCTAssert(actualResult.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "mockKey2", value: expectedValue2))
        })
    }
    
    func testDecode_WhenUnableToSerializeVCToken_ThrowsError() async throws {
        // Arrange
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let mockVC = MockVerifiableCredential(raw: "unserializableToken", contract: createMockSignedContract())
        let encodedMockVC = try encoder.encode(mockVC)
        
        // Act
        XCTAssertThrowsError(try decoder.decode(VerifiableCredential.self, from: encodedMockVC)) { error in
            // Assert
            XCTAssert(error is VerifiableCredentialMappingError)
            XCTAssertEqual(error as? VerifiableCredentialMappingError, .unableToDecodeRawVerifiableCredentialToken)
        }
    }
    
    func testDecode_WithValidInput_ReturnsVerifiableCredential() async throws {
        // Arrange
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let expectedSerializedVC = try createVCEntitiesVC().serialize()
        let expectedContract = createMockSignedContract()
        let mockVC = MockVerifiableCredential(raw: expectedSerializedVC, contract: expectedContract)
        let encodedMockVC = try encoder.encode(mockVC)
        
        // Act
        let actualResult = try decoder.decode(VerifiableCredential.self, from: encodedMockVC)
        
        // Assert
        XCTAssertEqual(try actualResult.raw.serialize(), expectedSerializedVC)
        XCTAssertEqual(actualResult.contract, expectedContract)
    }
    
    func testEncode_WithValidInput_CreatesEncodedVerifiableCredential() async throws {
        // Arrange
        
        // Act
        
        // Assert
    }
    
    private func createMockSignedContract(claims: [String: ClaimDisplayDescriptor] = [:]) -> Contract {
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
                                                      claims: claims)
        let mockContractInputDescriptor = ContractInputDescriptor(credentialIssuer: "mock credential issuer",
                                                                  issuer: "mock issuer",
                                                                  attestations: nil)
        return Contract(id: "mockContract",
                        display: mockDisplayDescriptor,
                        input: mockContractInputDescriptor)
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
                              vc: VerifiableCredentialDescriptor(context: [],
                                                                 type: [],
                                                                 credentialSubject: expectedClaims))
        return VCEntities.VerifiableCredential(headers: Header(), content: claims)!
    }
    
    private func areClaimsEqual(result: VerifiedIdClaim, expected: VerifiedIdClaim) -> Bool {
        return (result.id == expected.id) && (result.value as! String == expected.value as! String)
    }
}

struct MockVerifiableCredential: Codable {
    let raw: String
    
    let contract: Contract
}
