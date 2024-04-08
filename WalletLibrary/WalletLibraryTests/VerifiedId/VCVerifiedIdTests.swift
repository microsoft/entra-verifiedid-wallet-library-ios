/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VCVerifiedIdTests: XCTestCase {
    
    struct MockVerifiableCredential: Codable {
        let raw: String
        
        let contract: Contract
    }
    
    func testInit_WithValidInput_CreatesVerifiableCredential() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC()
        let mockContract = createMockSignedContract()

        // Act
        let actualResult = try VCVerifiedId(raw: mockVerifiableCredential, from: mockContract)
        
        // Assert
        XCTAssertEqual(try actualResult.raw.serialize(), try mockVerifiableCredential.serialize())
        XCTAssertEqual(actualResult.contract, mockContract)
        XCTAssertEqual(actualResult.expiresOn, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(actualResult.issuedOn, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(actualResult.id, mockVerifiableCredential.content.jti)
        XCTAssert(actualResult.style is BasicVerifiedIdStyle)
    }
    
    func testInit_WithMissingJtiOnVC_ThrowsError() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC(expectedJti: nil)
        let mockContract = createMockSignedContract()

        // Act
        XCTAssertThrowsError(try VCVerifiedId(raw: mockVerifiableCredential, from: mockContract)) { error in
            // Assert
            XCTAssert(error is VerifiableCredentialError)
            XCTAssertEqual(error as? VerifiableCredentialError, .missingJtiInVerifiableCredential)
        }
    }
    
    func testInit_WithMissingIatOnVC_ThrowsError() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC(expectedIat: nil)
        let mockContract = createMockSignedContract()

        // Act
        XCTAssertThrowsError(try VCVerifiedId(raw: mockVerifiableCredential, from: mockContract)) { error in
            // Assert
            XCTAssert(error is VerifiableCredentialError)
            XCTAssertEqual(error as? VerifiableCredentialError, .missingIssuedOnValueInVerifiableCredential)
        }
    }
    
    func testInit_WithNilExpOnVC_CreatesVerifiableCredential() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC(expectedExp: nil)
        let mockContract = createMockSignedContract()

        // Act
        let actualResult = try WalletLibrary.VCVerifiedId(raw: mockVerifiableCredential, from: mockContract)
        
        // Assert
        XCTAssertEqual(try actualResult.raw.serialize(), try mockVerifiableCredential.serialize())
        XCTAssertEqual(actualResult.contract, mockContract)
        XCTAssertNil(actualResult.expiresOn)
        XCTAssertEqual(actualResult.issuedOn, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(actualResult.id, mockVerifiableCredential.content.jti)
        XCTAssert(actualResult.style is BasicVerifiedIdStyle)
    }
    
    func testGetClaims_WithMissingCredentialSubjectInVC_ReturnsEmptyList() async throws {
        // Arrange
        let mockVerifiableCredential = createVCEntitiesVC()
        let mockContract = createMockSignedContract()
        let verifiableCredential = try VCVerifiedId(raw: mockVerifiableCredential,
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
        let expectedClaim1 = VerifiedIdClaim(id: "mockKey1", 
                                             label: nil,
                                             type: nil,
                                             value: expectedValue1)
        let expectedClaim2 = VerifiedIdClaim(id: "mockKey2", 
                                             label: nil,
                                             type: nil,
                                             value: expectedValue2)
        let mockVCClaimDictionary = ["mockKey1": expectedValue1, "mockKey2": expectedValue2]
        let mockVerifiableCredential = createVCEntitiesVC(expectedClaims: mockVCClaimDictionary)
        let mockContract = createMockSignedContract()
        let verifiableCredential = try VCVerifiedId(raw: mockVerifiableCredential,
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
        let mockVCClaimDictionary = ["mockKey1": expectedValue1]
        let mockVerifiableCredential = createVCEntitiesVC(expectedClaims: mockVCClaimDictionary)
        let expectedClaimLabel1 = ClaimDisplayDescriptor(type: "String",
                                                         label: "MockLabel1")
        let expectedClaimLabels = ["vc.credentialSubject.mockKey1": expectedClaimLabel1]
        let mockContract = createMockSignedContract(claims: expectedClaimLabels)
        let verifiableCredential = try VCVerifiedId(raw: mockVerifiableCredential,
                                                    from: mockContract)
        
        // Act
        let actualResult = verifiableCredential.getClaims()
        
        // Assert
        XCTAssertEqual(actualResult.count, 1)
        XCTAssert(actualResult.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "MockLabel1", 
                                                                 label: nil,
                                                                 type: "String",
                                                                 value: expectedValue1))
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
        
        let verifiableCredential = try VCVerifiedId(raw: mockVerifiableCredential,
                                                    from: mockContract)
        
        // Act
        let actualResult = verifiableCredential.getClaims()
        
        // Assert
        XCTAssertEqual(actualResult.count, 2)
        XCTAssert(actualResult.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "MockLabel1", 
                                                                 label: nil,
                                                                 type: "String",
                                                                 value: expectedValue1))
        })
        XCTAssert(actualResult.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "mockKey2", 
                                                                 label: nil,
                                                                 type: nil,
                                                                 value: expectedValue2))
        })
    }
    
    func testDecode_WhenUnableToSerializeVCToken_ThrowsError() async throws {
        // Arrange
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let mockVC = MockVerifiableCredential(raw: "unserializableToken", contract: createMockSignedContract())
        let encodedMockVC = try encoder.encode(mockVC)
        
        // Act
        XCTAssertThrowsError(try decoder.decode(VCVerifiedId.self, from: encodedMockVC)) { error in
            // Assert
            XCTAssert(error is VerifiableCredentialError)
            XCTAssertEqual(error as? VerifiableCredentialError, .unableToDecodeRawVerifiableCredentialToken)
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
        let actualResult = try decoder.decode(VCVerifiedId.self, from: encodedMockVC)
        
        // Assert
        XCTAssertEqual(try actualResult.raw.serialize(), expectedSerializedVC)
        XCTAssertEqual(actualResult.contract, expectedContract)
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
                                    expectedIat: Int? = 0,
                                    expectedExp: Int? = 0,
                                    expectedClaims: [String: String] = [:]) -> VerifiableCredential {
        let claims = VCClaims(jti: expectedJti,
                              iss: "",
                              sub: "",
                              iat: expectedIat,
                              exp: expectedExp,
                              vc: VerifiableCredentialDescriptor(context: [],
                                                                 type: [],
                                                                 credentialSubject: expectedClaims))
        return VerifiableCredential(headers: Header(), content: claims)!
    }
    
    private func areClaimsEqual(result: VerifiedIdClaim, expected: VerifiedIdClaim) -> Bool
    {
        return (result.id == expected.id) &&
        (result.value as! String == expected.value as! String) &&
        (result.type == expected.type)
    }
}
