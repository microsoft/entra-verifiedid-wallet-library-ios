/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class PresentationDescriptorMappingTests: XCTestCase {

    let mapper = Mapper()

    func testMap_WhenWithAllDefaultInput_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let (input, expectedResult) = try setUpInput(encrypted: false, required: false)
        
        // Act
        let actualResult = try mapper.map(input)
        
        // Assert
        assertEqual(actualResult, expectedResult)
    }

    func testMap_WhenEncyptedIsTrue_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let (input, expectedResult) = try setUpInput(encrypted: true, required: false)
        
        // Act
        let actualResult = try mapper.map(input)
        
        // Assert
        assertEqual(actualResult, expectedResult)
    }

    func testMap_WhenRequiredIsTrue_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let (input, expectedResult) = try setUpInput(encrypted: false, required: true)
        
        // Act
        let actualResult = try mapper.map(input)
        
        // Assert
        assertEqual(actualResult, expectedResult)
    }

    func testMap_WhenContractIsNil_ReturnsVerifiedIdRequiremen() throws {
        // Arrange
        let (input, expectedResult) = try setUpInput(contracts: nil)
        
        // Act
        let actualResult = try mapper.map(input)
        
        // Assert
        assertEqual(actualResult, expectedResult)
    }

    func testMap_WithOneContract_ReturnsVerifiedIdRequiremen() throws {
        // Arrange
        let (input, expectedResult) = try setUpInput(contracts: ["contract2645"])
        
        // Act
        let actualResult = try mapper.map(input)
        
        // Assert
        assertEqual(actualResult, expectedResult)
    }

    func testMap_WithThreeContracts_ReturnsVerifiedIdRequiremen() throws {
        // Arrange
        let (input, expectedResult) = try setUpInput(contracts: ["contract2645",
                                                                 "contract0394",
                                                                 "contract2343"])
        
        // Act
        let actualResult = try mapper.map(input)
        
        // Assert
        assertEqual(actualResult, expectedResult)
    }

    private func assertEqual(_ actual: VerifiedIdRequirement, _ expected: VerifiedIdRequirement) {
        XCTAssertEqual(actual.encrypted, expected.encrypted)
        XCTAssertEqual(actual.required, expected.required)
        XCTAssertEqual(actual.types, expected.types)
        XCTAssertEqual(actual.purpose, expected.purpose)
        XCTAssertEqual(actual.issuanceOptions as? [VerifiedIdRequestURL], expected.issuanceOptions as? [VerifiedIdRequestURL])
    }

    private func setUpInput(encrypted: Bool? = false,
                            required: Bool? = false,
                            credentialType: String = "credentialType",
                            contracts: [String]? = []) throws -> (PresentationDescriptor, VerifiedIdRequirement) {

        let input = PresentationDescriptor(encrypted: encrypted,
                                           claims: [],
                                           presentationRequired: required,
                                           credentialType: credentialType,
                                           issuers: nil,
                                           contracts: contracts)

        let expectedIssuanceOptions = contracts?.compactMap {
            
            if let contract = URL(string: $0) {
                return VerifiedIdRequestURL(url: contract)
            }
            
            return nil
        }

        let expectedResult = VerifiedIdRequirement(encrypted: encrypted ?? false,
                                                   required: required ?? false,
                                                   types: [credentialType],
                                                   purpose: nil,
                                                   issuanceOptions: expectedIssuanceOptions ?? [])
        return (input, expectedResult)
    }
}
