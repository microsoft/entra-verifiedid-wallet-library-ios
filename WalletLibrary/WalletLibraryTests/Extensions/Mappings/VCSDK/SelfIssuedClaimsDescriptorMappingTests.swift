/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class SelfIssuedClaimsDescriptorMappingTests: XCTestCase {
    
    private let mapper = Mapper()
    
    func testSuccessfulMapping() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: false)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithEncryptedAsTrueValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: true, required: false)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithEncryptedAsNilValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: nil, required: false)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithRequiredAsTrueValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: true)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithRequiredAsNilValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: nil)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithClaimsAsNilValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: false, claimDescriptors: nil)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithThreeClaimValues() throws {
        let claim1 = ClaimDescriptor(claim: "claim11", claimRequired: nil)
        let claim2 = ClaimDescriptor(claim: "claim22", claimRequired: false)
        let claim3 = ClaimDescriptor(claim: "claim33", claimRequired: true)
        let inputClaims = [claim1, claim2, claim3]
        let (input, expectedResult) = try setUpInput(encrypted: false, required: false, claimDescriptors: inputClaims)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    private func setUpInput(encrypted: Bool? = false,
                            required: Bool? = false,
                            claimDescriptors: [ClaimDescriptor]? = [ClaimDescriptor(claim: "claim2353")]) throws -> (SelfIssuedClaimsDescriptor, SelfAttestedClaimRequirements?) {

        let input = SelfIssuedClaimsDescriptor(encrypted: encrypted,
                                               claims: claimDescriptors,
                                               selfIssuedRequired: required)
        
        var expectedResult: SelfAttestedClaimRequirements? = nil
        
        if let claims = claimDescriptors,
           !claims.isEmpty {
            
            let requiredClaims = claims.compactMap {
                SelfAttestedClaimRequirement(required: $0.claimRequired ?? false,
                                             claim: $0.claim)
                
            }
            
            expectedResult = SelfAttestedClaimRequirements(encrypted: encrypted ?? false,
                                                               required: required ?? false,
                                                               requiredClaims: requiredClaims)

        }
        
        return (input, expectedResult)
    }
}
