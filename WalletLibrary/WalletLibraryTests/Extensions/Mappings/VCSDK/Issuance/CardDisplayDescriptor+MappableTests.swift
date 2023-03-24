/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class CardDisplayDescriptorMappingTests: XCTestCase {
    
    let title = "mockTitle"
    let issuer = "mockIssuer"
    let backgroundColor = "mockBackgroundColor"
    let textColor = "mockTextColor"
    let cardDescription = "mockDescription"
    
    func testMap_WithNilLogo_ReturnsVerifiedIdStyle() throws {
        // Arrange
        let mapper = Mapper()
        let cardDisplayDescriptor = CardDisplayDescriptor(title: title,
                                                          issuedBy: issuer,
                                                          backgroundColor: backgroundColor,
                                                          textColor: textColor,
                                                          logo: nil,
                                                          cardDescription: cardDescription)
        
        // Act
        let actualResult = try mapper.map(cardDisplayDescriptor) as! BasicVerifiedIdStyle
        
        // Assert
        XCTAssertEqual(actualResult.name, title)
        XCTAssertEqual(actualResult.issuer, issuer)
        XCTAssertEqual(actualResult.backgroundColor, backgroundColor)
        XCTAssertEqual(actualResult.textColor, textColor)
        XCTAssertEqual(actualResult.description, cardDescription)
        XCTAssertNil(actualResult.logoUrl)
        XCTAssertNil(actualResult.logoAltText)
    }
    
    func testMap_WithNilLogoDescription_ReturnsVerifiedIdStyle() throws {
        // Arrange
        let mapper = Mapper()
        let logo = LogoDisplayDescriptor(uri: "https://test.com",
                                         logoDescription: nil,
                                         image: nil)
        let cardDisplayDescriptor = CardDisplayDescriptor(title: title,
                                                          issuedBy: issuer,
                                                          backgroundColor: backgroundColor,
                                                          textColor: textColor,
                                                          logo: logo,
                                                          cardDescription: cardDescription)
        
        // Act
        let actualResult = try mapper.map(cardDisplayDescriptor) as! BasicVerifiedIdStyle
        
        // Assert
        XCTAssertEqual(actualResult.name, title)
        XCTAssertEqual(actualResult.issuer, issuer)
        XCTAssertEqual(actualResult.backgroundColor, backgroundColor)
        XCTAssertEqual(actualResult.textColor, textColor)
        XCTAssertEqual(actualResult.description, cardDescription)
        XCTAssertEqual(actualResult.logoUrl?.absoluteString, logo.uri)
        XCTAssertNil(actualResult.logoAltText)
    }
    
    func testMap_WithLogoAltText_ReturnsVerifiedIdStyle() throws {
        // Arrange
        let mapper = Mapper()
        let logo = LogoDisplayDescriptor(uri: "https://test.com",
                                         logoDescription: "mockAltText",
                                         image: nil)
        let cardDisplayDescriptor = CardDisplayDescriptor(title: title,
                                                          issuedBy: issuer,
                                                          backgroundColor: backgroundColor,
                                                          textColor: textColor,
                                                          logo: logo,
                                                          cardDescription: cardDescription)
        
        // Act
        let actualResult = try mapper.map(cardDisplayDescriptor) as! BasicVerifiedIdStyle
        
        // Assert
        XCTAssertEqual(actualResult.name, title)
        XCTAssertEqual(actualResult.issuer, issuer)
        XCTAssertEqual(actualResult.backgroundColor, backgroundColor)
        XCTAssertEqual(actualResult.textColor, textColor)
        XCTAssertEqual(actualResult.description, cardDescription)
        XCTAssertEqual(actualResult.logoUrl?.absoluteString, logo.uri)
        XCTAssertEqual(actualResult.logoAltText, logo.logoDescription)
    }
}
