/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class IdentifierFactoryTests: XCTestCase
{
    func testGetIdentifier_WithNoIdentifiers_ThrowError() throws
    {
        // Arrange
        let identifierFactory = IdentifierFactory(identifiers: [])
        
        // Act / Assert
        XCTAssertThrowsError(try identifierFactory.getIdentifier()) { error in
            XCTAssert(error is VerifiedIdError)
            let verifiedIdError = error as! VerifiedIdError
            XCTAssertEqual(verifiedIdError.code, "no_holder_identifier_found.")
            XCTAssertEqual(verifiedIdError.message, "No Holder Identifiers found.")
        }
    }
    
    func testGetIdentifier_WithNoMatchingIdentifier_ThrowError() throws
    {
        // Arrange
        let mockRequirement = MockCryptoRequirement()
        let mockHolder = MockHolderIdentifier(id: "did:test:microsoft.com")
        let identifierFactory = IdentifierFactory(identifiers: [mockHolder])
        
        // Act / Assert
        XCTAssertThrowsError(try identifierFactory.getIdentifier(for: mockRequirement)) { error in
            XCTAssert(error is VerifiedIdError)
            let verifiedIdError = error as! VerifiedIdError
            XCTAssertEqual(verifiedIdError.code, "no_holder_identifier_match_found.")
            XCTAssertEqual(verifiedIdError.message, "No Holder Identifier matches requirements.")
        }
    }
    
    func testGetIdentifier_WithNoCryptoReq_ReturnsFirstIdentifier() throws
    {
        // Arrange
        let mockHolder = MockHolderIdentifier()
        let identifierFactory = IdentifierFactory(identifiers: [mockHolder])
        
        // Act
        let result = try identifierFactory.getIdentifier()
        
        // Assert
        XCTAssertEqual(result as? MockHolderIdentifier, mockHolder)
    }
    
    func testGetIdentifier_WithMatchingIdentifier_ReturnsIdentifier() throws
    {
        // Arrange
        let mockHolderId = "did:test:microsoft.com"
        let mockHolder = MockHolderIdentifier(id: mockHolderId)
        let mockCryptoReq = MockCryptoRequirement(expectedIdentifierId: mockHolderId)
        let identifierFactory = IdentifierFactory(identifiers: [mockHolder])
        
        // Act
        let result = try identifierFactory.getIdentifier(for: mockCryptoReq)
        
        // Assert
        XCTAssertEqual(result as? MockHolderIdentifier, mockHolder)
    }
}

struct MockCryptoRequirement: CryptoRequirement
{
    
    let expectedIdentifierId: String
    
    init(expectedIdentifierId: String = "")
    {
        self.expectedIdentifierId = expectedIdentifierId
    }
    
    func isSupported(identifier: HolderIdentifier) -> Bool
    {
        expectedIdentifierId == identifier.id
    }
}
