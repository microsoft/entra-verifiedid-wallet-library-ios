/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class SelfIssuedClaimsDescriptorMappingTests: XCTestCase {
    
    func testMap_WithNilClaims_ReturnNil() throws {
        // Arrange
        let mapper = Mapper()
        let selfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor(encrypted: false,
                                                                    claims: nil,
                                                                    selfIssuedRequired: false)
        
        // Act
        let actualResult = try mapper.map(selfIssuedClaimsDescriptor)
        
        // Assert
        XCTAssertNil(actualResult)
    }
    
    func testMap_NoEmptyClaimArray_ReturnNil() throws {
        // Arrange
        let mapper = Mapper()
        let selfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor(encrypted: false,
                                                                    claims: [],
                                                                    selfIssuedRequired: false)
        
        // Act
        let actualResult = try mapper.map(selfIssuedClaimsDescriptor)
        
        // Assert
        XCTAssertNil(actualResult)
    }
    
    func testMap_WithOneSelfIssuedClaimsDescriptor_ReturnsSelfAttestedRequirement() throws {
        // Arrange
        let mapper = Mapper()
        
        let mockClaimValue = "mock claim"
        let expectedSelfAttestedRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                           required: false,
                                                                           claim: mockClaimValue)
        let mockClaim = ClaimDescriptor(claim: mockClaimValue, claimRequired: false)
        let selfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor(encrypted: false,
                                                                    claims: [mockClaim],
                                                                    selfIssuedRequired: false)
        
        // Act
        let actualResult = try mapper.map(selfIssuedClaimsDescriptor)
        
        // Assert
        XCTAssert(actualResult is SelfAttestedClaimRequirement)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.required, expectedSelfAttestedRequirement.required)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.claim, expectedSelfAttestedRequirement.claim)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.encrypted, expectedSelfAttestedRequirement.encrypted)
    }
    
    func testMap_WithOneEncryptedSelfIssuedClaimsDescriptor_ReturnsSelfAttestedRequirement() throws {
        // Arrange
        let mapper = Mapper()
        
        let mockClaimValue = "mock claim"
        let expectedSelfAttestedRequirement = SelfAttestedClaimRequirement(encrypted: true,
                                                                           required: false,
                                                                           claim: mockClaimValue)
        let mockClaim = ClaimDescriptor(claim: mockClaimValue, claimRequired: false)
        let selfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor(encrypted: true,
                                                                    claims: [mockClaim],
                                                                    selfIssuedRequired: false)
        
        // Act
        let actualResult = try mapper.map(selfIssuedClaimsDescriptor)
        
        // Assert
        XCTAssert(actualResult is SelfAttestedClaimRequirement)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.required, expectedSelfAttestedRequirement.required)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.claim, expectedSelfAttestedRequirement.claim)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.encrypted, expectedSelfAttestedRequirement.encrypted)
    }
    
    func testMap_WithSelfIssuedClaimsDescriptorWithOneRequiredClaim_ReturnsSelfAttestedRequirement() throws {
        // Arrange
        let mapper = Mapper()
        
        let mockClaimValue = "mock claim"
        let expectedSelfAttestedRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                           required: true,
                                                                           claim: mockClaimValue)
        let mockClaim = ClaimDescriptor(claim: mockClaimValue, claimRequired: true)
        let selfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor(encrypted: false,
                                                                    claims: [mockClaim],
                                                                    selfIssuedRequired: false)
        
        // Act
        let actualResult = try mapper.map(selfIssuedClaimsDescriptor)
        
        // Assert
        XCTAssert(actualResult is SelfAttestedClaimRequirement)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.required, expectedSelfAttestedRequirement.required)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.claim, expectedSelfAttestedRequirement.claim)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.encrypted, expectedSelfAttestedRequirement.encrypted)
    }
    
    func testMap_WithOneRequiredSelfIssuedClaimsDescriptor_ReturnsSelfAttestedRequirement() throws {
        // Arrange
        let mapper = Mapper()
        
        let mockClaimValue = "mock claim"
        let expectedSelfAttestedRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                           required: true,
                                                                           claim: mockClaimValue)
        let mockClaim = ClaimDescriptor(claim: mockClaimValue, claimRequired: false)
        let selfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor(encrypted: false,
                                                                    claims: [mockClaim],
                                                                    selfIssuedRequired: true)
        
        // Act
        let actualResult = try mapper.map(selfIssuedClaimsDescriptor)
        
        // Assert
        XCTAssert(actualResult is SelfAttestedClaimRequirement)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.required, expectedSelfAttestedRequirement.required)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.claim, expectedSelfAttestedRequirement.claim)
        XCTAssertEqual((actualResult as? SelfAttestedClaimRequirement)?.encrypted, expectedSelfAttestedRequirement.encrypted)
    }
    
    func testMap_WithMultipleSelfIssuedClaimsAndAllClaimsRequired_ReturnGroupRequirement() throws {
        // Arrange
        let mapper = Mapper()
        
        let firstMockClaimValue = "first mock claim"
        let secondMockClaimValue = "second mock claim"
        let thirdMockClaimValue = "third mock claim"
        
        
        let expectedFirstSelfAttestedRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                                required: false,
                                                                                claim: firstMockClaimValue)
        let expectedSecondSelfAttestedRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                                 required: true,
                                                                                 claim: secondMockClaimValue)
        let expectedThirdSelfAttestedRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                                required: false,
                                                                                claim: thirdMockClaimValue)
        
        let firstMockClaim = ClaimDescriptor(claim: firstMockClaimValue, claimRequired: false)
        let secondMockClaim = ClaimDescriptor(claim: secondMockClaimValue, claimRequired: true)
        let thirdMockClaim = ClaimDescriptor(claim: thirdMockClaimValue, claimRequired: false)
        
        let selfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor(encrypted: false,
                                                                    claims: [firstMockClaim, secondMockClaim, thirdMockClaim],
                                                                    selfIssuedRequired: true)
        
        // Act
        let actualResult = try mapper.map(selfIssuedClaimsDescriptor)
        
        // Assert
        XCTAssert(actualResult is GroupRequirement)
        
        if let groupRequirement = actualResult as? GroupRequirement,
           let requirements = groupRequirement.requirements as? [SelfAttestedClaimRequirement] {
            XCTAssert(groupRequirement.required)
            XCTAssertEqual(requirements.count, 3)
            XCTAssertEqual(requirements.first?.required, expectedFirstSelfAttestedRequirement.required)
            XCTAssertEqual(requirements.first?.claim, expectedFirstSelfAttestedRequirement.claim)
            XCTAssertEqual(requirements.first?.encrypted, expectedFirstSelfAttestedRequirement.encrypted)
            XCTAssertEqual(requirements[1].required, expectedSecondSelfAttestedRequirement.required)
            XCTAssertEqual(requirements[1].claim, expectedSecondSelfAttestedRequirement.claim)
            XCTAssertEqual(requirements[1].encrypted, expectedSecondSelfAttestedRequirement.encrypted)
            XCTAssertEqual(requirements[2].required, expectedThirdSelfAttestedRequirement.required)
            XCTAssertEqual(requirements[2].claim, expectedThirdSelfAttestedRequirement.claim)
            XCTAssertEqual(requirements[2].encrypted, expectedThirdSelfAttestedRequirement.encrypted)
            
        } else {
            XCTFail("Group Requirement not returned.")
        }
    }
    
    func testMap_WithMultipleSelfIssuedClaimsAndAllClaimsNotRequired_ReturnsGroupRequirement() throws {
        // Arrange
        let mapper = Mapper()
        
        let firstMockClaimValue = "first mock claim"
        let secondMockClaimValue = "second mock claim"
        let thirdMockClaimValue = "third mock claim"
        
        
        let expectedFirstSelfAttestedRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                                required: true,
                                                                                claim: firstMockClaimValue)
        let expectedSecondSelfAttestedRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                                 required: false,
                                                                                 claim: secondMockClaimValue)
        let expectedThirdSelfAttestedRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                                required: true,
                                                                                claim: thirdMockClaimValue)
        
        let firstMockClaim = ClaimDescriptor(claim: firstMockClaimValue, claimRequired: true)
        let secondMockClaim = ClaimDescriptor(claim: secondMockClaimValue, claimRequired: false)
        let thirdMockClaim = ClaimDescriptor(claim: thirdMockClaimValue, claimRequired: true)
        
        let selfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor(encrypted: false,
                                                                    claims: [firstMockClaim, secondMockClaim, thirdMockClaim],
                                                                    selfIssuedRequired: false)
        
        // Act
        let actualResult = try mapper.map(selfIssuedClaimsDescriptor)
        
        // Assert
        XCTAssert(actualResult is GroupRequirement)
        
        if let groupRequirement = actualResult as? GroupRequirement,
           let requirements = groupRequirement.requirements as? [SelfAttestedClaimRequirement] {
            XCTAssertFalse(groupRequirement.required)
            XCTAssertEqual(requirements.count, 3)
            XCTAssertEqual(requirements.first?.required, expectedFirstSelfAttestedRequirement.required)
            XCTAssertEqual(requirements.first?.claim, expectedFirstSelfAttestedRequirement.claim)
            XCTAssertEqual(requirements.first?.encrypted, expectedFirstSelfAttestedRequirement.encrypted)
            XCTAssertEqual(requirements[1].required, expectedSecondSelfAttestedRequirement.required)
            XCTAssertEqual(requirements[1].claim, expectedSecondSelfAttestedRequirement.claim)
            XCTAssertEqual(requirements[1].encrypted, expectedSecondSelfAttestedRequirement.encrypted)
            XCTAssertEqual(requirements[2].required, expectedThirdSelfAttestedRequirement.required)
            XCTAssertEqual(requirements[2].claim, expectedThirdSelfAttestedRequirement.claim)
            XCTAssertEqual(requirements[2].encrypted, expectedThirdSelfAttestedRequirement.encrypted)
            
        } else {
            XCTFail("Group Requirement not returned.")
        }
    }
}
