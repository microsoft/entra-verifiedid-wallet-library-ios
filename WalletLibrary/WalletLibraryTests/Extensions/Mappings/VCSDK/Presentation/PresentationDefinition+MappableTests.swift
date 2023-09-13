/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationDefinitionMappingTests: XCTestCase {
    
    func testMap_WithNilInputDescriptors_ThrowsError() throws {
        
        // Arrange
        let mockMapper = MockMapper()
        let presentationDefinition = PresentationDefinition(id: nil,
                                                            inputDescriptors: nil,
                                                            issuance: nil)
        
        // Act
        XCTAssertThrowsError(try mockMapper.map(presentationDefinition)) { error in
            // Assert
            XCTAssert(error is PresentationDefinitionMappingError)
            XCTAssertEqual(error as? PresentationDefinitionMappingError, .missingInputDescriptors)
        }
    }
    
    func testMap_NoInputDescriptors_ThrowsError() throws {
        
        // Arrange
        let mockMapper = MockMapper()
        let presentationDefinition = PresentationDefinition(id: nil,
                                                            inputDescriptors: [],
                                                            issuance: nil)
        
        // Act
        XCTAssertThrowsError(try mockMapper.map(presentationDefinition)) { error in
            // Assert
            XCTAssert(error is PresentationDefinitionMappingError)
            XCTAssertEqual(error as? PresentationDefinitionMappingError, .missingInputDescriptors)
        }
    }
    
    func testMap_WithOneInputDescriptorPresent_ReturnsVerifiedIdRequirement() throws {
        
        // Arrange
        let inputDescriptor = PresentationInputDescriptor(id: "mock id",
                                                          schema: [InputDescriptorSchema(uri: "mock type")],
                                                          issuanceMetadata: nil,
                                                          name: nil,
                                                          purpose: nil,
                                                          constraints: nil)
        let presentationDefinition = PresentationDefinition(id: nil,
                                                            inputDescriptors: [inputDescriptor],
                                                            issuance: nil)
        
        let mapper = Mapper()
        
        // Act
        let actualResult = try mapper.map(presentationDefinition)
        
        // Assert
        XCTAssert(actualResult is [VerifiedIdRequirement])
        XCTAssertEqual(actualResult.count, 1)
        XCTAssertEqual((actualResult.first as? VerifiedIdRequirement)?.types, ["mock type"])
        XCTAssertEqual((actualResult.first as? VerifiedIdRequirement)?.id, "mock id")
    }
    
    func testMap_WithMultipleInputDescriptorPresent_ReturnsGroupRequirement() throws {
        
        // Arrange
        let mockVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                              required: false,
                                                              types: [],
                                                              purpose: nil,
                                                              issuanceOptions: [],
                                                              id: nil,
                                                              constraint: GroupConstraint(constraints: [],
                                                                                          constraintOperator: .ALL))
        let firstMockInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                   schema: nil,
                                                                   issuanceMetadata: nil,
                                                                   name: nil,
                                                                   purpose: nil,
                                                                   constraints: nil)
        let secondMockInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                    schema: nil,
                                                                    issuanceMetadata: nil,
                                                                    name: nil,
                                                                    purpose: nil,
                                                                    constraints: nil)
        let thirdMockInputDescriptor = PresentationInputDescriptor(id: nil,
                                                                   schema: nil,
                                                                   issuanceMetadata: nil,
                                                                   name: nil,
                                                                   purpose: nil,
                                                                   constraints: nil)
        let inputDescriptors = [firstMockInputDescriptor, secondMockInputDescriptor, thirdMockInputDescriptor]
        let presentationDefinition = PresentationDefinition(id: nil,
                                                            inputDescriptors: inputDescriptors,
                                                            issuance: nil)
        
        var requirementCount = 0
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is PresentationInputDescriptor {
                requirementCount = requirementCount + 1
                return mockVerifiedIdRequirement
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mockMapper.map(presentationDefinition)
        
        // Assert
        XCTAssert(actualResult is [VerifiedIdRequirement])
        XCTAssertEqual(actualResult.count, requirementCount)
        XCTAssertIdentical(actualResult.first as AnyObject, mockVerifiedIdRequirement as AnyObject)
        XCTAssertIdentical(actualResult[1] as AnyObject, mockVerifiedIdRequirement as AnyObject)
        XCTAssertIdentical(actualResult[2] as AnyObject, mockVerifiedIdRequirement as AnyObject)
    }
}
