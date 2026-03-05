/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class KeychainHolderIdentifierBuilderTests: XCTestCase
{
    private let keyReference = "mockKeyReference"
    private let algorithm = "mockAlgorithm"
    private let didJwk = "did:jwk"
    
    func testBuildHolderIdentifier_WhenInvalidDIDMethod_ThrowError() throws
    {
        // Arrange
        let invalidDIDMethod = "did:invalid"
        
        let mockCryptoOperations = MockCryptoOperations()
        let mockKeyManagementOperations = MockKeyManagementOperations(secretStore: SecretStoreMock())
        let builder = KeychainHolderIdentifierBuilder(logger:  WalletLibraryLogger(), keyManagementOperations: mockKeyManagementOperations,
                                                      cryptoOperations: mockCryptoOperations)
        
        // Act / Assert
        XCTAssertThrowsError(try builder.buildHolderIdentifier(didMethod: invalidDIDMethod,
                                                               keyReference: keyReference,
                                                               algorithm: algorithm)) { error in
            XCTAssert(error is IdentifierError)
            
            guard let identifierError = error as? IdentifierError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "unsupported_did_method")
            XCTAssertEqual(identifierError.message, "Unsupported DID Method: did:invalid.")
            
        }
    }
    
    func testBuildHolderIdentifier_WhenUnableToGenerateKey_ThrowError() throws
    {
        // Arrange
        let expectedError = VerifiedIdError(message: "ExpectedGenerateKeyError", code: "expected_error")
        let mockCryptoOperations = MockCryptoOperations()
        let mockKeyManagementOperations = MockKeyManagementOperations(secretStore: SecretStoreMock(),
                                                                      expectedGenerateKeyError: expectedError)
        let builder = KeychainHolderIdentifierBuilder(logger:  WalletLibraryLogger(), keyManagementOperations: mockKeyManagementOperations,
                                                      cryptoOperations: mockCryptoOperations)
        
        // Act / Assert
        XCTAssertThrowsError(try builder.buildHolderIdentifier(didMethod: didJwk,
                                                               keyReference: keyReference,
                                                               algorithm: algorithm)) { error in
            XCTAssert(error is VerifiedIdError)
            
            guard let identifierError = error as? VerifiedIdError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, expectedError.code)
            XCTAssertEqual(identifierError.message, expectedError.message)
            
        }
    }
    
    func testBuildHolderIdentifier_WhenUnableToGetPublicKey_ThrowError() throws
    {
        // Arrange
        let mockCryptoOperations = MockCryptoOperations(throwWhenGettingPublicKey: true)
        let mockKeyManagementOperations = MockKeyManagementOperations(secretStore: SecretStoreMock())
        let builder = KeychainHolderIdentifierBuilder(logger:  WalletLibraryLogger(), keyManagementOperations: mockKeyManagementOperations,
                                                      cryptoOperations: mockCryptoOperations)
        
        // Act / Assert
        XCTAssertThrowsError(try builder.buildHolderIdentifier(didMethod: didJwk,
                                                               keyReference: keyReference,
                                                               algorithm: algorithm)) { error in
            XCTAssertEqual(error as? MockCryptoError, .ExpectedToThrow)
            
        }
    }
    
    func testBuildHolderIdentifier_WhenUnableToBuildDID_ThrowError() throws
    {
        // Arrange
        let mockCryptoOperations = MockCryptoOperations()
        let mockKeyManagementOperations = MockKeyManagementOperations(secretStore: SecretStoreMock())
        let builder = KeychainHolderIdentifierBuilder(logger:  WalletLibraryLogger(), keyManagementOperations: mockKeyManagementOperations,
                                                      cryptoOperations: mockCryptoOperations)
        
        // Act / Assert
        XCTAssertThrowsError(try builder.buildHolderIdentifier(didMethod: didJwk,
                                                               keyReference: keyReference,
                                                               algorithm: algorithm)) { error in
            XCTAssert(error is IdentifierError)
            
            guard let identifierError = error as? IdentifierError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "invalid_public_key")
            XCTAssertEqual(identifierError.message, "Invalid Key Type: Secp256k1PublicKey.")
            
        }
    }
    
    func testBuildHolderIdentifier_WhenValidInputs_ReturnsHolderIdentifier() throws
    {
        let mockPublicKey = ES256PublicKey(x: Data(count: 32), y: Data(count: 32))!
        let mockCryptoOperations = MockCryptoOperations(publicKey: mockPublicKey)
        let mockKeyManagementOperations = MockKeyManagementOperations(secretStore: SecretStoreMock())
        let builder = KeychainHolderIdentifierBuilder(logger:  WalletLibraryLogger(), keyManagementOperations: mockKeyManagementOperations,
                                                      cryptoOperations: mockCryptoOperations)
        
        // Act
        let result = try builder.buildHolderIdentifier(didMethod: didJwk,
                                                       keyReference: keyReference,
                                                       algorithm: algorithm)
        
        // Assert
        XCTAssert(result is KeychainIdentifier)
        XCTAssert(result.id.starts(with: "did:jwk:"))
        XCTAssertEqual(result.algorithm, algorithm)
        XCTAssertEqual(result.keyReference, "mockKeyReference")
        XCTAssertEqual(result.method, didJwk)
    }
}
