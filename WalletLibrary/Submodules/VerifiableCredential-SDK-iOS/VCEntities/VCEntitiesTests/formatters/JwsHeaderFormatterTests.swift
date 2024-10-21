/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class JwsHeaderFormatterTests: XCTestCase 
{
    private let formatter = JwsHeaderFormatter()
    
    func testFormatHeaders_WithKeyContainer_ReturnHeader() async throws
    {
        // Arrange
        let mockKeyId = "mockKeyId1"
        let mockIdentifier = "did:test:microsoft.com"
        let mockSecret = MockCryptoSecret(id: UUID())
        let mockKeyContainer = KeyContainer(keyReference: mockSecret, keyId: mockKeyId)
        
        // Act
        let result = formatter.formatHeaders(identifier: mockIdentifier,
                                             signingKey: mockKeyContainer)
        
        // Assert
        XCTAssertEqual(result.algorithm, mockKeyContainer.algorithm)
        XCTAssertEqual(result.keyId, "\(mockIdentifier)#\(mockKeyId)")
        XCTAssertEqual(result.type, "JWT")
        XCTAssertNil(result.encryptionMethod)
        XCTAssertNil(result.pbes2Count)
        XCTAssertNil(result.pbes2SaltInput)
        XCTAssertNil(result.contentType)
        XCTAssertNil(result.jsonWebKey)
    }
    
    func testFormatHeaders_WithHolderIdentifier_ReturnHeader() async throws
    {
        // Arrange
        let mockKeyId = "mockKeyId1"
        let mockMethod = "did:test"
        let mockIdentifier = "did:test:microsoft.com"
        let mockAlgorithm = "mockAlgorithm"
        let mockSecret = MockCryptoSecret(id: UUID())
        let mockCryptoOperations = MockCryptoOperations()
        let holder = KeychainIdentifier(id: mockIdentifier,
                                            algorithm: mockAlgorithm,
                                            method: mockMethod,
                                            keyReference: mockKeyId,
                                            keyReferenceSecret: mockSecret,
                                            cryptoOperations: mockCryptoOperations)
        
        // Act
        let result = formatter.formatHeaders(identifier: holder)
        
        // Assert
        XCTAssertEqual(result.algorithm, mockAlgorithm)
        XCTAssertEqual(result.keyId, "\(mockIdentifier)#\(mockKeyId)")
        XCTAssertEqual(result.type, "JWT")
        XCTAssertNil(result.encryptionMethod)
        XCTAssertNil(result.pbes2Count)
        XCTAssertNil(result.pbes2SaltInput)
        XCTAssertNil(result.contentType)
        XCTAssertNil(result.jsonWebKey)
    }
}
