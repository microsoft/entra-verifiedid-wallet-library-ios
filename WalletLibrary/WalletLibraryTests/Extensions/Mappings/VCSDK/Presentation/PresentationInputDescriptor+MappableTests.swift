/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationInputDescriptorMappingTests: XCTestCase {
    
    func testMap_WithNilSchema_ThrowsError() throws {
        // Arrange
        let mockMapper = MockMapper()
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                      schema: nil,
                                                                      issuanceMetadata: nil,
                                                                      name: nil,
                                                                      purpose: nil,
                                                                      constraints: nil)
        
        // Act
        XCTAssertThrowsError(try mockMapper.map(presentationInputDescriptor)) { error in
            // Assert
            XCTAssert(error is PresentationInputDescriptorMappingError)
            XCTAssertEqual(error as? PresentationInputDescriptorMappingError, .noVerifiedIdTypeInPresentationInputDescriptor)
        }
    }
    
    func testMap_WithNilVerifiedIdTypePresent_ThrowsError() throws {
        // Arrange
        let mockMapper = MockMapper()
        let schema = InputDescriptorSchema(uri: nil)
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                      schema: [schema],
                                                                      issuanceMetadata: nil,
                                                                      name: nil,
                                                                      purpose: nil,
                                                                      constraints: nil)
        
        // Act
        XCTAssertThrowsError(try mockMapper.map(presentationInputDescriptor)) { error in
            // Assert
            XCTAssert(error is PresentationInputDescriptorMappingError)
            XCTAssertEqual(error as? PresentationInputDescriptorMappingError, .noVerifiedIdTypeInPresentationInputDescriptor)
        }
    }
    
    func testMap_WithNoVerifiedIdTypesPresent_ThrowsError() throws {
        // Arrange
        let mockMapper = MockMapper()
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                      schema: [],
                                                                      issuanceMetadata: nil,
                                                                      name: nil,
                                                                      purpose: nil,
                                                                      constraints: nil)
        
        // Act
        XCTAssertThrowsError(try mockMapper.map(presentationInputDescriptor)) { error in
            // Assert
            XCTAssert(error is PresentationInputDescriptorMappingError)
            XCTAssertEqual(error as? PresentationInputDescriptorMappingError, .noVerifiedIdTypeInPresentationInputDescriptor)
        }
    }
    
    func testMap_WithOneTypePresent_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let mockSchema = InputDescriptorSchema(uri: "mockType")
        let expectedVerifiedIdRequest = VerifiedIdRequirement(encrypted: false,
                                                              required: true,
                                                              types: ["mockType"],
                                                              purpose: nil,
                                                              issuanceOptions: [],
                                                              id: nil,
                                                              constraint: GroupConstraint(constraints: [],
                                                                                          constraintOperator: .ALL))
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                      schema: [mockSchema],
                                                                      issuanceMetadata: nil,
                                                                      name: nil,
                                                                      purpose: nil,
                                                                      constraints: nil)
        
        // Act
        let actualResult = try mockMapper.map(presentationInputDescriptor)
        
        // Assert
        XCTAssertEqual(actualResult.encrypted, expectedVerifiedIdRequest.encrypted)
        XCTAssertEqual(actualResult.required, expectedVerifiedIdRequest.required)
        XCTAssertEqual(actualResult.types, expectedVerifiedIdRequest.types)
        XCTAssertEqual(actualResult.issuanceOptions as? [VerifiedIdRequestURL], [])
        XCTAssertEqual(actualResult.purpose, expectedVerifiedIdRequest.purpose)
        XCTAssert(actualResult.constraint is VCTypeConstraint)
        XCTAssertEqual((actualResult.constraint as? VCTypeConstraint)?.type, "mockType")
        XCTAssertEqual(actualResult.id, expectedVerifiedIdRequest.id)
    }
    
    func testMap_WithMultipleTypesPresent_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let firstType = "firstType"
        let secondType = "secondType"
        let thirdType = "thirdType"
        let firstSchema = InputDescriptorSchema(uri: firstType)
        let secondSchema = InputDescriptorSchema(uri: secondType)
        let thirdSchema = InputDescriptorSchema(uri: thirdType)
        let expectedVerifiedIdRequest = VerifiedIdRequirement(encrypted: false,
                                                              required: true,
                                                              types: [firstType, secondType, thirdType],
                                                              purpose: nil,
                                                              issuanceOptions: [],
                                                              id: nil,
                                                              constraint: GroupConstraint(constraints: [],
                                                                                          constraintOperator: .ALL))
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                      schema: [firstSchema, secondSchema, thirdSchema],
                                                                      issuanceMetadata: nil,
                                                                      name: nil,
                                                                      purpose: nil,
                                                                      constraints: nil)
        
        // Act
        let actualResult = try mockMapper.map(presentationInputDescriptor)
        
        // Assert
        XCTAssertEqual(actualResult.encrypted, expectedVerifiedIdRequest.encrypted)
        XCTAssertEqual(actualResult.required, expectedVerifiedIdRequest.required)
        XCTAssertEqual(actualResult.types, expectedVerifiedIdRequest.types)
        XCTAssertEqual(actualResult.issuanceOptions as? [VerifiedIdRequestURL], [])
        XCTAssertEqual(actualResult.purpose, expectedVerifiedIdRequest.purpose)
        XCTAssert(actualResult.constraint is GroupConstraint)
        let constraints = (actualResult.constraint as? GroupConstraint)!.constraints
        XCTAssertEqual(constraints.count, 3)
        XCTAssertEqual((constraints[0] as? VCTypeConstraint)?.type, firstType)
        XCTAssertEqual((constraints[1] as? VCTypeConstraint)?.type, secondType)
        XCTAssertEqual((constraints[2] as? VCTypeConstraint)?.type, thirdType)
        XCTAssertEqual(actualResult.id, expectedVerifiedIdRequest.id)
    }
    
    func testMap_WithNoIssuanceMetadataPresent_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let mockSchema = InputDescriptorSchema(uri: "mockType")
        let expectedVerifiedIdRequest = VerifiedIdRequirement(encrypted: false,
                                                              required: true,
                                                              types: ["mockType"],
                                                              purpose: nil,
                                                              issuanceOptions: [],
                                                              id: nil,
                                                              constraint: GroupConstraint(constraints: [],
                                                                                          constraintOperator: .ALL))
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                      schema: [mockSchema],
                                                                      issuanceMetadata: nil,
                                                                      name: nil,
                                                                      purpose: nil,
                                                                      constraints: nil)
        
        // Act
        let actualResult = try mockMapper.map(presentationInputDescriptor)
        
        // Assert
        XCTAssertEqual(actualResult.encrypted, expectedVerifiedIdRequest.encrypted)
        XCTAssertEqual(actualResult.required, expectedVerifiedIdRequest.required)
        XCTAssertEqual(actualResult.types, expectedVerifiedIdRequest.types)
        XCTAssertEqual(actualResult.issuanceOptions as? [VerifiedIdRequestURL], [])
        XCTAssertEqual(actualResult.purpose, expectedVerifiedIdRequest.purpose)
        XCTAssert(actualResult.constraint is VCTypeConstraint)
        XCTAssertEqual((actualResult.constraint as? VCTypeConstraint)?.type, "mockType")
        XCTAssertEqual(actualResult.id, expectedVerifiedIdRequest.id)
    }
    
    func testMap_WithInvalidContractFormatInIssuanceMetadata_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let mockSchema = InputDescriptorSchema(uri: "mockType")
        let mockId = "mockId"
        let invalidContract = "//|\\"
        let invalidIssuanceMetadata = IssuanceMetadata(contract: invalidContract, issuerDid: nil)
        let expectedVerifiedIdRequest = VerifiedIdRequirement(encrypted: false,
                                                              required: true,
                                                              types: ["mockType"],
                                                              purpose: nil,
                                                              issuanceOptions: [],
                                                              id: mockId,
                                                              constraint: GroupConstraint(constraints: [],
                                                                                          constraintOperator: .ALL))
        let presentationInputDescriptor = PresentationInputDescriptor(id: mockId,
                                                                      schema: [mockSchema],
                                                                      issuanceMetadata: [invalidIssuanceMetadata],
                                                                      name: nil,
                                                                      purpose: nil,
                                                                      constraints: nil)
        
        // Act
        let actualResult = try mockMapper.map(presentationInputDescriptor)
        
        // Assert
        XCTAssertEqual(actualResult.encrypted, expectedVerifiedIdRequest.encrypted)
        XCTAssertEqual(actualResult.required, expectedVerifiedIdRequest.required)
        XCTAssertEqual(actualResult.types, expectedVerifiedIdRequest.types)
        XCTAssertEqual(actualResult.issuanceOptions as? [VerifiedIdRequestURL], [])
        XCTAssertEqual(actualResult.purpose, expectedVerifiedIdRequest.purpose)
        XCTAssert(actualResult.constraint is VCTypeConstraint)
        XCTAssertEqual((actualResult.constraint as? VCTypeConstraint)?.type, "mockType")
        XCTAssertEqual(actualResult.id, expectedVerifiedIdRequest.id)
    }
    
    func testMap_WithOneInvalidContractAndTwoValidContractsPresent_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let mockSchema = InputDescriptorSchema(uri: "mockType")
        let mockId = "mockId"
        let invalidContract = "//|\\"
        let firstValidContract = "https://mockcontract1.com"
        let secondValidContract = "https://mockcontract2.com"
        
        let invalidIssuanceMetadata = IssuanceMetadata(contract: invalidContract, issuerDid: nil)
        let firstValidIssuanceMetadata = IssuanceMetadata(contract: firstValidContract, issuerDid: nil)
        let secondValidIssuanceMetadata = IssuanceMetadata(contract: secondValidContract, issuerDid: nil)
        
        let firstVerifiedIdRequestURL = VerifiedIdRequestURL(url: URL(string: firstValidContract)!)
        let secondVerifiedIdRequestURL = VerifiedIdRequestURL(url: URL(string: secondValidContract)!)
        
        let expectedVerifiedIdRequest = VerifiedIdRequirement(encrypted: false,
                                                              required: true,
                                                              types: ["mockType"],
                                                              purpose: nil,
                                                              issuanceOptions: [firstVerifiedIdRequestURL,
                                                                                secondVerifiedIdRequestURL],
                                                              id: nil,
                                                              constraint: GroupConstraint(constraints: [],
                                                                                          constraintOperator: .ALL))
        
        let issuanceMetadatas = [firstValidIssuanceMetadata, invalidIssuanceMetadata, secondValidIssuanceMetadata]
        let presentationInputDescriptor = PresentationInputDescriptor(id: mockId,
                                                                      schema: [mockSchema],
                                                                      issuanceMetadata: issuanceMetadatas,
                                                                      name: nil,
                                                                      purpose: nil,
                                                                      constraints: nil)
        
        // Act
        let actualResult = try mockMapper.map(presentationInputDescriptor)
        
        // Assert
        XCTAssertEqual(actualResult.encrypted, expectedVerifiedIdRequest.encrypted)
        XCTAssertEqual(actualResult.required, expectedVerifiedIdRequest.required)
        XCTAssertEqual(actualResult.types, expectedVerifiedIdRequest.types)
        XCTAssertEqual(actualResult.issuanceOptions as? [VerifiedIdRequestURL], [firstVerifiedIdRequestURL,
                                                                                 secondVerifiedIdRequestURL])
        XCTAssertEqual(actualResult.purpose, expectedVerifiedIdRequest.purpose)
        XCTAssert(actualResult.constraint is VCTypeConstraint)
        XCTAssertEqual((actualResult.constraint as? VCTypeConstraint)?.type, "mockType")
        XCTAssertEqual(actualResult.id, mockId)
    }
    
    func testMap_WithPurposePresent_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let mockSchema = InputDescriptorSchema(uri: "mockType")
        let purpose = "purpose of the requirement."
        let expectedVerifiedIdRequest = VerifiedIdRequirement(encrypted: false,
                                                              required: true,
                                                              types: ["mockType"],
                                                              purpose: purpose,
                                                              issuanceOptions: [],
                                                              id: nil,
                                                              constraint: GroupConstraint(constraints: [],
                                                                                          constraintOperator: .ALL))
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                      schema: [mockSchema],
                                                                      issuanceMetadata: nil,
                                                                      name: nil,
                                                                      purpose: purpose,
                                                                      constraints: nil)
        
        // Act
        let actualResult = try mockMapper.map(presentationInputDescriptor)
        
        // Assert
        XCTAssertEqual(actualResult.encrypted, expectedVerifiedIdRequest.encrypted)
        XCTAssertEqual(actualResult.required, expectedVerifiedIdRequest.required)
        XCTAssertEqual(actualResult.types, expectedVerifiedIdRequest.types)
        XCTAssertEqual(actualResult.issuanceOptions as? [VerifiedIdRequestURL], [])
        XCTAssertEqual(actualResult.purpose, expectedVerifiedIdRequest.purpose)
        XCTAssert(actualResult.constraint is VCTypeConstraint)
        XCTAssertEqual((actualResult.constraint as? VCTypeConstraint)?.type, "mockType")
    }
    
    func testMap_WithInvalidPresentationExchangeFieldConstraint_ThrowsError() throws {
        // Arrange
        let mockMapper = MockMapper()
        let mockSchema = InputDescriptorSchema(uri: "mockType")
        let invalidField = PresentationExchangeField(path: [],
                                                     purpose: nil,
                                                     filter: nil)
        let constraint = PresentationExchangeConstraints(fields: [invalidField])
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                      schema: [mockSchema],
                                                                      issuanceMetadata: nil,
                                                                      name: nil,
                                                                      purpose: nil,
                                                                      constraints: constraint)
        
        // Act
        XCTAssertThrowsError(try mockMapper.map(presentationInputDescriptor)) { error in
            // Assert
            XCTAssert(error is PresentationExchangeFieldConstraintError)
            XCTAssertEqual(error as? PresentationExchangeFieldConstraintError, .NoPathsFoundOnPresentationExchangeField)
        }
    }
    
    func testMap_WitOnePresentationExchangeFieldConstraint_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let mockSchema = InputDescriptorSchema(uri: "mockType")
        let field = PresentationExchangeField(path: ["mock path"],
                                              purpose: nil,
                                              filter: PresentationExchangeFilter(pattern: try NSRegularExpression(pattern: "test")))
        let constraint = PresentationExchangeConstraints(fields: [field])
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                      schema: [mockSchema],
                                                                      issuanceMetadata: nil,
                                                                      name: nil,
                                                                      purpose: nil,
                                                                      constraints: constraint)
        
        // Act
        let actualResult = try mockMapper.map(presentationInputDescriptor)
        
        // Assert
        XCTAssertFalse(actualResult.encrypted)
        XCTAssertTrue(actualResult.required)
        XCTAssertEqual(actualResult.types, ["mockType"])
        XCTAssertEqual(actualResult.issuanceOptions as? [VerifiedIdRequestURL], [])
        XCTAssertNil(actualResult.purpose)
        XCTAssert(actualResult.constraint is GroupConstraint)
        let groupConstraint = actualResult.constraint as! GroupConstraint
        XCTAssertEqual(groupConstraint.constraints.count, 2)
        XCTAssert(groupConstraint.constraints.contains { ($0 as? VCTypeConstraint)?.type == "mockType"} )
        XCTAssert(groupConstraint.constraints.contains { $0 is PresentationExchangeFieldConstraint } )
    }
    
    func testMap_WitThreePresentationExchangeFieldConstraint_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let mockSchema = InputDescriptorSchema(uri: "mockType")
        let mockFilter = PresentationExchangeFilter(pattern: try NSRegularExpression(pattern: "test"))
        let field = PresentationExchangeField(path: ["mock path"],
                                              purpose: nil,
                                              filter: mockFilter)
        let field2 = PresentationExchangeField(path: ["mock path 2"],
                                              purpose: nil,
                                              filter: mockFilter)
        let field3 = PresentationExchangeField(path: ["mock path 3"],
                                              purpose: nil,
                                              filter: mockFilter)
        let constraint = PresentationExchangeConstraints(fields: [field, field2, field3])
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                      schema: [mockSchema],
                                                                      issuanceMetadata: nil,
                                                                      name: nil,
                                                                      purpose: nil,
                                                                      constraints: constraint)
        
        // Act
        let actualResult = try mockMapper.map(presentationInputDescriptor)
        
        // Assert
        XCTAssertFalse(actualResult.encrypted)
        XCTAssertTrue(actualResult.required)
        XCTAssertEqual(actualResult.types, ["mockType"])
        XCTAssertEqual(actualResult.issuanceOptions as? [VerifiedIdRequestURL], [])
        XCTAssertNil(actualResult.purpose)
        XCTAssert(actualResult.constraint is GroupConstraint)
        let groupConstraint = actualResult.constraint as! GroupConstraint
        XCTAssertEqual(groupConstraint.constraints.count, 4)
        XCTAssert(groupConstraint.constraints.contains { ($0 as? VCTypeConstraint)?.type == "mockType"} )
        
        var counter = 0
        for constraint in groupConstraint.constraints {
            if constraint is PresentationExchangeFieldConstraint {
                counter = counter + 1
            }
        }

        XCTAssertEqual(counter, 3)
    }
}
