/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary
import XCTest

class PresentationExchangePatternTests: XCTestCase {
    
    func testMatches_WithStartsWithAndMatchAtStart_ReturnsTrue() throws {
        // Arrange
        let mockInput = "/^joe/gi"
        let filter = PresentationExchangePattern(from: mockInput)
        
        // Act
        let result = filter!.matches(in: "joe starts with input.")
        
        // Assert
        XCTAssert(result)
    }
    
    func testMatches_WithStartsWithAndNoMatchAtStart_ReturnsTrue() throws {
        // Arrange
        let mockInput = "/^joe/gi"
        let filter = PresentationExchangePattern(from: mockInput)
        
        // Act
        let result = filter!.matches(in: "no match at beginning, joe.")
        
        // Assert
        XCTAssertFalse(result)
    }
    
    func testMatches_WithContainsAndMatches_ReturnsTrue() throws {
        // Arrange
        let mockInput = "/joe/gi"
        let filter = PresentationExchangePattern(from: mockInput)
        
        // Act
        let result = filter!.matches(in: "input contains joe.")
        
        // Assert
        XCTAssert(result)
    }
    
    func testMatches_WithContainsAndNoMatch_ReturnsTrue() throws {
        // Arrange
        let mockInput = "/joe/gi"
        let filter = PresentationExchangePattern(from: mockInput)
        
        // Act
        let result = filter!.matches(in: "no match.")
        
        // Assert
        XCTAssertFalse(result)
    }
    
    func testMatches_WithOneValueAndMatches_ReturnsTrue() throws {
        // Arrange
        let mockInput = "/^joe$/gi"
        let filter = PresentationExchangePattern(from: mockInput)
        
        // Act
        let result = filter!.matches(in: "joe")
        
        // Assert
        XCTAssert(result)
    }
    
    func testMatches_WithOneValueAndNoMatch_ReturnsFalse() throws {
        // Arrange
        let mockInput = "/^joe$/gi"
        let filter = PresentationExchangePattern(from: mockInput)
        
        // Act
        let result = filter!.matches(in: "no joe.")
        
        // Assert
        XCTAssertFalse(result)
    }
    
    func testMatches_WithValuesAndMatches_ReturnsTrue() throws {
        // Arrange
        let mockInput = "/^joe|john$/gi"
        let filter = PresentationExchangePattern(from: mockInput)
        
        // Act
        let result = filter!.matches(in: "joe")
        
        // Assert
        XCTAssert(result)
    }
    
    func testMatches_WithValuesAndMatches2_ReturnsTrue() throws {
        // Arrange
        let mockInput = "/^joe|john$/gi"
        let filter = PresentationExchangePattern(from: mockInput)
        
        // Act
        let result = filter!.matches(in: "john")
        
        // Assert
        XCTAssert(result)
    }
    
    func testMatches_WithValuesAndNoMatch_ReturnsFalse() throws {
        // Arrange
        let mockInput = "/^joe|john$/gi"
        let filter = PresentationExchangePattern(from: mockInput)
        
        // Act
        let result = filter!.matches(in: "no match.")
        
        // Assert
        XCTAssertFalse(result)
    }
}
