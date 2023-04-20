/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class LinkedDomainResultMappingTests: XCTestCase {
    
    let mapper = Mapper()
    
    func testMap_WithLinkedDomainMissing_ReturnsRootOfTrust() throws {
        // Arrange
        let linkedDomainResult = LinkedDomainResult.linkedDomainMissing
        let expectedResult = RootOfTrust(verified: false, source: nil)
        
        // Act
        let actualResult = try mapper.map(linkedDomainResult)
        
        // Assert
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMap_WithLinkedDomainVerified_ReturnsRootOfTrust() throws {
        // Arrange
        let mockDomain = "verifiedDomain342"
        let linkedDomainResult = LinkedDomainResult.linkedDomainVerified(domainUrl: mockDomain)
        let expectedResult = RootOfTrust(verified: true, source: mockDomain)
        
        // Act
        let actualResult = try mapper.map(linkedDomainResult)
        
        // Assert
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMap_WithLinkedDomainUnverified_ReturnsRootOfTrust() throws {
        // Arrange
        let mockDomain = "unverifiedDomain235"
        let linkedDomainResult = LinkedDomainResult.linkedDomainUnverified(domainUrl: mockDomain)
        let expectedResult = RootOfTrust(verified: false, source: mockDomain)
        
        // Act
        let actualResult = try mapper.map(linkedDomainResult)
        
        // Assert
        XCTAssertEqual(actualResult, expectedResult)
    }
}
