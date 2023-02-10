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
            XCTAssertEqual(error as? PresentationDefinitionMappingError, .nilInputDescriptors)
        }
    }
    
    func testMap_WithOneInputDescriptorPresent_ReturnsVerifiedIdRequirement() throws {
        
        // Arrange
        let mockVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
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
        
        func callback(type: Any) throws -> Any? {
            if type is PresentationInputDescriptor {
                return mockVerifiedIdRequirement
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(callback: callback)
        
        let actualResult = try mockMapper.map(presentationDefinition)
        
        // Assert
        XCTAssertIdentical(actualResult as AnyObject, mockVerifiedIdRequirement as AnyObject)
    }
    
    func testMap_WithMultipleInputDescriptorPresent_ReturnsGroupRequirement() throws {
        // Arrange
//        let (input, expectedResult) = try setUpInput(encrypted: false, required: false)
        
        // Act
//        let actualResult = try mapper.map(input)
        
        // Assert
//        assertEqual(actualResult, expectedResult)
    }
}
