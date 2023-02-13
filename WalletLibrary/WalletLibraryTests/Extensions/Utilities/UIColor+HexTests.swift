/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import UIKit
@testable import WalletLibrary

class UIColorHexExtensionTests: XCTestCase {
    
    func testInit_WithValidColorWithInputOfLength6_ReturnUIColor() throws {
        // Arrange
        let input = "#000000"
        let expectedColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        // Act
        let actualResult = UIColor(hex: input)
        
        // Assert
        XCTAssertEqual(expectedColor, actualResult)
    }
    
    func testInit_WithValidColorWIthInputOfLength6_ReturnUIColor() throws {
        // Arrange
        let input = "#fff"
        let expectedColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Act
        let actualResult = UIColor(hex: input)
        
        // Assert
        XCTAssertEqual(expectedColor, actualResult)
    }
    
    func testInit_WithInvalidLettersInInput_ReturnNil() throws {
        // Arrange
        let input = "#YZ"
        
        // Act
        let actualResult = UIColor(hex: input)
        
        // Assert
        XCTAssertEqual(nil, actualResult)
    }
    
    func testInit_WithInvalidNumberOfCharactersInInput_ReturnNil() throws {
        // Arrange
        let input = "#A1244"
        
        // Act
        let actualResult = UIColor(hex: input)
        
        // Assert
        XCTAssertEqual(nil, actualResult)
    }
    
    func testInit_WithSpacesBetweenCharacters_ReturnsUIColor() throws {
        // Arrange
        let input = "#000000      "
        let expectedColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        // Act
        let actualResult = UIColor(hex: input)
        
        // Assert
        XCTAssertEqual(expectedColor, actualResult)
    }
    
//    it('with all six characters a valid corresponding rgb value should be returned', function () {
//      hexToRgb('#f1f1f1').should.equal('rgb(241, 241, 241)');
//    });
//
//    it('with three characters a valid corresponding rgb value should be returned', function () {
//      hexToRgb('#fff').should.equal('rgb(255, 255, 255)');
//    })
}
