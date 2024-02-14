/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class DataExtensionTests: XCTestCase 
{
    func testBase64URLEncodedWithNoPaddingString_WithEmptyData_ReturnsEmptyString() throws 
    {
        // Arrange
        let emptyData = Data()
        
        // Act / Assert
        XCTAssertEqual(emptyData.base64URLEncodedWithNoPaddingString(), "")
        
    }
     
    func testBase64URLEncodedWithNoPaddingString_WithSimpleString_ReturnsBase64URLEncodedString() throws 
    {
        // Arrange
        let inputString = "Hello, World!"
        
        // Act
        if let inputData = inputString.data(using: .utf8)
        {
            let base64URLString = inputData.base64URLEncodedWithNoPaddingString()
            
            // Assert
            XCTAssertEqual(base64URLString, "SGVsbG8sIFdvcmxkIQ")
        } 
        else
        {
            XCTFail("Failed to convert input string to Data.")
        }
    }
    
    func testBase64URLEncodedWithNoPaddingString_WithBinaryDataAndNoSpecialChars_ReturnsBase64URLEncodedString() throws 
    {
        // Arrange
        let binaryData = Data([0x01, 0x02, 0x03, 0x04, 0x05])
        
        // Act / Assert
        XCTAssertEqual(binaryData.base64URLEncodedWithNoPaddingString(), "AQIDBAU")
    }
    
    func testBase64URLEncodedWithNoPaddingString_WithBinaryDataAndSpecialChar_ReturnsBase64URLEncodedString() throws 
    {
        // Arrange
        let specialCharacters = Data([0x00, 0xFF, 0x7F, 0x2B, 0x2F])
        
        // Act / Assert
        XCTAssertEqual(specialCharacters.base64URLEncodedWithNoPaddingString(), "AP9_Ky8")
    }
}
