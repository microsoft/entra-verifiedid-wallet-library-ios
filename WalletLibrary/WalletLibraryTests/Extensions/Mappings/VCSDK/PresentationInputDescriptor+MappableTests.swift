/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
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
                                                              issuanceOptions: [])
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
                                                              issuanceOptions: [])
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
    }
    
    func testMap_WithNoIssuanceMetadataPresent_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let mockSchema = InputDescriptorSchema(uri: "mockType")
        let expectedVerifiedIdRequest = VerifiedIdRequirement(encrypted: false,
                                                              required: true,
                                                              types: ["mockType"],
                                                              purpose: nil,
                                                              issuanceOptions: [])
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
    }
    
    func testMap_WithInvalidContractFormatInIssuanceMetadata_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let mockSchema = InputDescriptorSchema(uri: "mockType")
        let invalidContract = "//|\\"
        let invalidIssuanceMetadata = IssuanceMetadata(contract: invalidContract, issuerDid: nil)
        let expectedVerifiedIdRequest = VerifiedIdRequirement(encrypted: false,
                                                              required: true,
                                                              types: ["mockType"],
                                                              purpose: nil,
                                                              issuanceOptions: [])
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
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
    }
    
    func testMap_WithOneInvalidContractAndTwoValidContractsPresent_ReturnsVerifiedIdRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let mockSchema = InputDescriptorSchema(uri: "mockType")
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
                                                              issuanceOptions: [firstVerifiedIdRequestURL, secondVerifiedIdRequestURL])
        
        let issuanceMetadatas = [firstValidIssuanceMetadata, invalidIssuanceMetadata, secondValidIssuanceMetadata]
        let presentationInputDescriptor = PresentationInputDescriptor(id: nil,
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
        XCTAssertEqual(actualResult.issuanceOptions as? [VerifiedIdRequestURL], [firstVerifiedIdRequestURL, secondVerifiedIdRequestURL])
        XCTAssertEqual(actualResult.purpose, expectedVerifiedIdRequest.purpose)
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
                                                              issuanceOptions: [])
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
    }
}
