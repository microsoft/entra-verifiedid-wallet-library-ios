/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class PresentationDescriptorMappingTests: XCTestCase {
    
    let mapper = Mapper()
    
    let encoder = JSONEncoder()
    
    let decoder = JSONDecoder()
    
    let exceptedCredentialType = "credentialType4235"
    
    func testSuccessfulMapping() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: false)
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithEncryptedAsTrue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: true, required: false)
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithRequiredAsTrue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: true)
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithOneNilIssuerValue() throws {
        let (input, expectedResult) = try setUpInput(issuers: [nil])
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithOneIssuerValue() throws {
        let (input, expectedResult) = try setUpInput(issuers: ["issuer235"])
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithThreeIssuerValue() throws {
        let (input, expectedResult) = try setUpInput(issuers: ["issuer235",
                                                               "issuer7345",
                                                               "issuer9083"])
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithNilIssuerValue() throws {
        let (input, expectedResult) = try setUpInput(issuers: nil)
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithNilContractValue() throws {
        let (input, expectedResult) = try setUpInput(contracts: nil)
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithOneContractValue() throws {
        let (input, expectedResult) = try setUpInput(contracts: ["contract2645"])
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithThreeContractValue() throws {
        let (input, expectedResult) = try setUpInput(contracts: ["contract2645",
                                                                 "contract0394",
                                                                 "contract2343"])
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    private func assertEqual(_ actual: VerifiedIdRequirement, _ expected: VerifiedIdRequirement) {
        XCTAssertEqual(actual.encrypted, expected.encrypted)
        XCTAssertEqual(actual.required, expected.required)
        XCTAssertEqual(actual.types, expected.types)
        XCTAssertEqual(actual.acceptedIssuers, expected.acceptedIssuers)
        XCTAssertEqual(actual.purpose, expected.purpose)
        XCTAssertEqual(actual.issuanceOptions, expected.issuanceOptions)
    }
    
    private func setUpInput(encrypted: Bool? = false,
                            required: Bool? = false,
                            issuers: [String?]? = [],
                            contracts: [String]? = []) throws -> (PresentationDescriptor, VerifiedIdRequirement) {
        
        let issuersInput = issuers?.compactMap { IssuerDescriptor(iss: $0) }
        let input = PresentationDescriptor(encrypted: encrypted,
                                           claims: [],
                                           presentationRequired: required,
                                           credentialType: exceptedCredentialType,
                                           issuers: issuersInput,
                                           contracts: contracts)
        
        let expectedIssuers = issuers?.compactMap { $0 } ?? []
        
        var expectedIssuanceOptions: IssuanceOptions? = nil
        if let expectedContracts = contracts,
           !expectedContracts.isEmpty {
            expectedIssuanceOptions = IssuanceOptions(acceptedIssuers: expectedIssuers,
                                                     credentialIssuerMetadata: expectedContracts)
        }
        
        let expectedResult = VerifiedIdRequirement(encrypted: encrypted ?? false,
                                                   required: required ?? false,
                                                   types: [exceptedCredentialType],
                                                   acceptedIssuers: expectedIssuers,
                                                   purpose: nil,
                                                   issuanceOptions: expectedIssuanceOptions)
        return (input, expectedResult)
    }
}
