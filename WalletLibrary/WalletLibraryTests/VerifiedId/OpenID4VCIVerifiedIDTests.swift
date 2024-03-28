/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenID4VCIVerifiedIDTests: XCTestCase
{
    struct MockVerifiableCredential: Codable
    {
        let vc: String
        
        let configuration: CredentialConfiguration
        
        let issuerName: String
    }
    
    func testInit_WithInvalidRawToken_ThrowsError() async throws
    {
        // Arrange
        let mockRaw = "mock raw"
        let mockIssuerName = "mock issuer name"
        let mockConfig = createCredentialConfiguration()
        
        // Act / Assert
        XCTAssertThrowsError(try OpenID4VCIVerifiedId(raw: mockRaw,
                                                      issuerName: mockIssuerName,
                                                      configuration: mockConfig)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .InvalidProperty(property: "rawToken", in: "raw"))
        }
    }
    
    func testInit_WithNilIat_ThrowsError() async throws
    {
        // Arrange
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: [],
                                                                         claims: [:],
                                                                         issuer: "",
                                                                         iat: nil)
        let rawVC = try mockVC.serialize()
        let mockIssuerName = "mock issuer name"
        let mockConfig = createCredentialConfiguration()
        
        // Act / Assert
        XCTAssertThrowsError(try OpenID4VCIVerifiedId(raw: rawVC,
                                                      issuerName: mockIssuerName,
                                                      configuration: mockConfig)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: "iat", in: "VCClaims"))
        }
    }
    
    func testInit_WithNilJTI_ThrowsError() async throws
    {
        // Arrange
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: [],
                                                                         claims: [:],
                                                                         issuer: "",
                                                                         jti: nil)
        let rawVC = try mockVC.serialize()
        let mockIssuerName = "mock issuer name"
        let mockConfig = createCredentialConfiguration()
        
        // Act / Assert
        XCTAssertThrowsError(try OpenID4VCIVerifiedId(raw: rawVC,
                                                      issuerName: mockIssuerName,
                                                      configuration: mockConfig)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: "jti", in: "VCClaims"))
        }
    }
    
    func testInit_WithValidInputs_ReturnsVerifiedID() async throws
    {
        // Arrange
        let mockIssuerDID = "mock issuer DID"
        let mockTypes = ["mockType1", "mockType2"]
        let mockID = "mock ID"
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: mockTypes,
                                                                         claims: [:],
                                                                         issuer: mockIssuerDID,
                                                                         jti: mockID)
        let rawVC = try mockVC.serialize()
        let mockIssuerName = "mock issuer name"
        let mockConfig = createCredentialConfiguration()
        
        // Act
        let result = try OpenID4VCIVerifiedId(raw: rawVC,
                                              issuerName: mockIssuerName,
                                              configuration: mockConfig)
        
        // Assert
        XCTAssertEqual(try result.raw.serialize(), rawVC)
        XCTAssertEqual(result.id, mockID)
        XCTAssertEqual(result.issuerName, mockIssuerName)
        XCTAssertEqual(result.types, mockTypes)
        XCTAssertEqual(result.expiresOn, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(result.issuedOn, Date(timeIntervalSince1970: 0))
        XCTAssert(result.style is BasicVerifiedIdStyle)
    }
    
    func testEncode_WithValidInputs_EncodesVCProperly() async throws
    {
        // Arrange
        let mockIssuerDID = "mock issuer DID"
        let mockTypes = ["mockType1", "mockType2"]
        let mockID = "mock ID"
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: mockTypes,
                                                                         claims: [:],
                                                                         issuer: mockIssuerDID,
                                                                         jti: mockID)
        let rawVC = try mockVC.serialize()
        let mockIssuerName = "mock issuer name"
        let mockConfig = createCredentialConfiguration()
        
        let vc = try OpenID4VCIVerifiedId(raw: rawVC,
                                          issuerName: mockIssuerName,
                                          configuration: mockConfig)
        
        let mockEncoded = MockVerifiableCredential(vc: rawVC,
                                                   configuration: mockConfig,
                                                   issuerName: mockIssuerName)
        let expected = try JSONEncoder().encode(mockEncoded)
        
        // Act
        let result = try JSONEncoder().encode(vc)
        
        // Assert
        XCTAssertEqual(result, expected)
    }
    
    func testDecode_WithValidInputs_EncodesVCProperly() async throws
    {
        // Arrange
        let mockIssuerDID = "mock issuer DID"
        let mockTypes = ["mockType1", "mockType2"]
        let mockID = "mock ID"
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: mockTypes,
                                                                         claims: [:],
                                                                         issuer: mockIssuerDID,
                                                                         jti: mockID)
        let rawVC = try mockVC.serialize()
        let mockIssuerName = "mock issuer name"
        let mockConfig = createCredentialConfiguration()
        
        let mockEncoded = MockVerifiableCredential(vc: rawVC,
                                                   configuration: mockConfig,
                                                   issuerName: mockIssuerName)
        let encodedVC = try JSONEncoder().encode(mockEncoded)
        
        // Act
        let result = try JSONDecoder().decode(OpenID4VCIVerifiedId.self, from: encodedVC)
        
        // Assert
        XCTAssertEqual(try result.raw.serialize(), rawVC)
        XCTAssertEqual(result.id, mockID)
        XCTAssertEqual(result.issuerName, mockIssuerName)
        XCTAssertEqual(result.types, mockTypes)
        XCTAssertEqual(result.expiresOn, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(result.issuedOn, Date(timeIntervalSince1970: 0))
        XCTAssert(result.style is BasicVerifiedIdStyle)
    }
    
    func testGetClaims_WithNoClaims_ReturnsEmptyList() async throws
    {
        // Arrange
        let mockIssuerDID = "mock issuer DID"
        let mockTypes = ["mockType1", "mockType2"]
        let mockID = "mock ID"
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: mockTypes,
                                                                         claims: [:],
                                                                         issuer: mockIssuerDID,
                                                                         jti: mockID)
        let rawVC = try mockVC.serialize()
        let mockIssuerName = "mock issuer name"
        let mockConfig = createCredentialConfiguration()
        
        let vc = try OpenID4VCIVerifiedId(raw: rawVC,
                                          issuerName: mockIssuerName,
                                          configuration: mockConfig)
        
        // Act
        let result = vc.getClaims()
        
        // Assert
        XCTAssert(result.isEmpty)
    }
    
    func testGetClaims_WithoutDisplayClaims_ReturnsClaims() async throws
    {
        // Arrange
        let expectedValue1 = "mockValue1"
        let expectedValue2 = "mockValue2"
        
        let claimsInVC = ["mockKey1": expectedValue1, "mockKey2": expectedValue2]
        
        let claimsInDisplay: [String: String] = [:]
        let claimTypes = "mockClaimTypes"
        
        let mockIssuerDID = "mock issuer DID"
        let mockTypes = ["mockType1", "mockType2"]
        let mockID = "mock ID"
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: mockTypes,
                                                                         claims: claimsInVC,
                                                                         issuer: mockIssuerDID,
                                                                         jti: mockID)
        let rawVC = try mockVC.serialize()
        let mockIssuerName = "mock issuer name"
        let mockConfig = createCredentialConfiguration(claims: claimsInDisplay,
                                                       claimTypes: claimTypes)
        
        let vc = try OpenID4VCIVerifiedId(raw: rawVC,
                                          issuerName: mockIssuerName,
                                          configuration: mockConfig)
        
        // Act
        let result = vc.getClaims()
        
        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssert(result.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "mockKey1",
                                                                 type: nil,
                                                                 value: expectedValue1))
        })
        XCTAssert(result.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "mockKey2",
                                                                 type: nil,
                                                                 value: expectedValue2))
        })
    }
    
    func testGetClaims_WithDisplayClaimsWithNilTypes_ReturnsClaims() async throws
    {
        // Arrange
        let expectedValue1 = "mockValue1"
        let expectedValue2 = "mockValue2"
        
        let claimsInVC = ["mockKey1": expectedValue1, "mockKey2": expectedValue2]
        
        let claimsInDisplay: [String: String] = ["mockKey1": "MockLabel1",
                                                 "mockKey2": "MockLabel2"]
        
        let mockIssuerDID = "mock issuer DID"
        let mockTypes = ["mockType1", "mockType2"]
        let mockID = "mock ID"
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: mockTypes,
                                                                         claims: claimsInVC,
                                                                         issuer: mockIssuerDID,
                                                                         jti: mockID)
        let rawVC = try mockVC.serialize()
        let mockIssuerName = "mock issuer name"
        let mockConfig = createCredentialConfiguration(claims: claimsInDisplay)
        
        let vc = try OpenID4VCIVerifiedId(raw: rawVC,
                                          issuerName: mockIssuerName,
                                          configuration: mockConfig)
        
        // Act
        let result = vc.getClaims()
        
        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssert(result.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "MockLabel1",
                                                                 type: nil,
                                                                 value: expectedValue1))
        })
        XCTAssert(result.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "MockLabel2",
                                                                 type: nil,
                                                                 value: expectedValue2))
        })
    }
    
    func testGetClaims_WithDisplayClaimsWithMockTypes_ReturnsClaims() async throws
    {
        // Arrange
        let expectedValue1 = "mockValue1"
        let expectedValue2 = "mockValue2"
        
        let claimsInVC = ["mockKey1": expectedValue1, "mockKey2": expectedValue2]
        
        let claimsInDisplay: [String: String] = ["mockKey1": "MockLabel1",
                                                 "mockKey2": "MockLabel2"]
        
        let mockIssuerDID = "mock issuer DID"
        let mockTypes = ["mockType1", "mockType2"]
        let mockID = "mock ID"
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: mockTypes,
                                                                         claims: claimsInVC,
                                                                         issuer: mockIssuerDID,
                                                                         jti: mockID)
        let rawVC = try mockVC.serialize()
        let mockIssuerName = "mock issuer name"
        let mockConfig = createCredentialConfiguration(claims: claimsInDisplay, claimTypes: "mockType")
        
        let vc = try OpenID4VCIVerifiedId(raw: rawVC,
                                          issuerName: mockIssuerName,
                                          configuration: mockConfig)
        
        // Act
        let result = vc.getClaims()
        
        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssert(result.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "MockLabel1",
                                                                 type: "mockType",
                                                                 value: expectedValue1))
        })
        XCTAssert(result.contains {
            areClaimsEqual(result: $0, expected: VerifiedIdClaim(id: "MockLabel2",
                                                                 type: "mockType",
                                                                 value: expectedValue2))
        })
    }
    
    private func createCredentialConfiguration(claims: [String: String] = [:],
                                               claimTypes: String? = nil) -> CredentialConfiguration
    {
        let displayDefinition = createDisplayDefinition(claims: claims, claimTypes: claimTypes)
        let credentialDefinition = CredentialDefinition(type: nil,
                                                        credential_subject: displayDefinition)
        let config = CredentialConfiguration(format: nil,
                                             scope: nil,
                                             cryptographic_binding_methods_supported: nil,
                                             cryptographic_suites_supported: nil,
                                             credential_definition: credentialDefinition,
                                             display: nil,
                                             proof_types_supported: nil)
        return config
    }
    
    private func createDisplayDefinition(claims: [String: String], claimTypes: String?) -> [String: CredentialSubjectDefinition]
    {
        var result: [String: CredentialSubjectDefinition] = [:]
        claims.forEach { key, value in
            
            let localizedDisplayDefinition = LocalizedDisplayDefinition(name: value,
                                                                        locale: "en",
                                                                        logo: nil,
                                                                        description: nil,
                                                                        background_color: nil,
                                                                        text_color: nil)
            let credentialSubjectDefinition = CredentialSubjectDefinition(display: [localizedDisplayDefinition],
                                                                          value_type: claimTypes)
            result["vc.credentialSubject.\(key)"] = credentialSubjectDefinition
        }
        return result
    }
    
    private func areClaimsEqual(result: VerifiedIdClaim, expected: VerifiedIdClaim) -> Bool
    {
        return (result.id == expected.id) &&
        (result.value as! String == expected.value as! String) &&
        (result.type == expected.type)
    }
}
