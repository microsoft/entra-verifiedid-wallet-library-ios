/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class PresentationRequestMappingTests: XCTestCase {
    
    let mapper = Mapper()
    
    func testMap_WithNoPresentationDefinitionPresent_ThrowsError() throws {
//        // Arrange
//        let presentationRequestToken = PresentationRequestToken(headers: Header(),
//                                                                content: PresentationRequestClaims()
        
        // Act
//        let actualResult = try mapper.map(input)
        
        // Assert
//        assertEqual(actualResult, expectedResult)
    }
    
    func testMap_WithInvalidPresentationDefinition_ThrowsError() throws {
        // Arrange
//        let (input, expectedResult) = try setUpInput(encrypted: false, required: false)
        
        // Act
//        let actualResult = try mapper.map(input)
        
        // Assert
//        assertEqual(actualResult, expectedResult)
    }
    
    func testMap_WithInvalidRootOfTrust_ThrowsError() throws {
        // Arrange
//        let (input, expectedResult) = try setUpInput(encrypted: false, required: false)
        
        // Act
//        let actualResult = try mapper.map(input)
        
        // Assert
//        assertEqual(actualResult, expectedResult)
    }
    
    func testMap_WithNoClientNamePresent_ReturnVerifiedIdRequestContent() throws {
        // Arrange
//        let (input, expectedResult) = try setUpInput(encrypted: false, required: false)
        
        // Act
//        let actualResult = try mapper.map(input)
        
        // Assert
//        assertEqual(actualResult, expectedResult)
    }
    
    func testMap_WithClientNamePresent_ReturnVerifiedIdRequestContent() throws {
        // Arrange
//        let (input, expectedResult) = try setUpInput(encrypted: false, required: false)
        
        // Act
//        let actualResult = try mapper.map(input)
        
        // Assert
//        assertEqual(actualResult, expectedResult)
    }
}
