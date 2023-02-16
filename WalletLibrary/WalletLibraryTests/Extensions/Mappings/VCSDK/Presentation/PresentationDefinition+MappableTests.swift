/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
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
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                              required: false,
                                                              types: [],
                                                              purpose: nil,
                                                              issuanceOptions: [])
        let inputDescriptor = PresentationInputDescriptor(id: nil,
                                                          schema: nil,
                                                          issuanceMetadata: nil,
                                                          name: nil,
                                                          purpose: nil,
                                                          constraints: nil)
        let presentationDefinition = PresentationDefinition(id: nil,
                                                            inputDescriptors: [inputDescriptor],
                                                            issuance: nil)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is PresentationInputDescriptor {
                return expectedVerifiedIdRequirement
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mockMapper.map(presentationDefinition)
        
        // Assert
        XCTAssert(actualResult is VerifiedIdRequirement)
        XCTAssertIdentical(actualResult as AnyObject, expectedVerifiedIdRequirement as AnyObject)
    }
    
    func testMap_WithMultipleInputDescriptorPresent_ReturnsGroupRequirement() throws {
        
        // Arrange
        let mockVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                              required: false,
                                                              types: [],
                                                              purpose: nil,
                                                              issuanceOptions: [])
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
        XCTAssert(actualResult is GroupRequirement)
        XCTAssertEqual((actualResult as? GroupRequirement)?.requirements.count, requirementCount)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements.first as AnyObject, mockVerifiedIdRequirement as AnyObject)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements[1] as AnyObject, mockVerifiedIdRequirement as AnyObject)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements[2] as AnyObject, mockVerifiedIdRequirement as AnyObject)
        XCTAssert((actualResult as? GroupRequirement)?.required ?? false)
        XCTAssertEqual((actualResult as? GroupRequirement)?.requirementOperator, .ALL)
    }
}
