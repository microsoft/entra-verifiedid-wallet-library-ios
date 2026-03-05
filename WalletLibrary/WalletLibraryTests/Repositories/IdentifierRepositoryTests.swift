/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class IdentifierRepositoryTests: XCTestCase
{
    func testGetMainHolderIdentifier_WhenFetchingStoredObjectThrows_ThrowError() throws
    {
        // Arrange
        let expectedError = VerifiedIdError(message: "ExpectedError", code: "expected_error")
        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: nil,
                                                      expectedHolderIdentifier: nil)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: expectedError,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger: WalletLibraryLogger(), builder: mockBuilder,
                                              storage: mockStorage)
        
        // Act / Assert
        XCTAssertThrowsError(try repository.getMainHolderIdentifier()) { error in
            
            XCTAssert(error is VerifiedIdError)
            
            guard let identifierError = error as? VerifiedIdError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "expected_error")
            XCTAssertEqual(identifierError.message, "ExpectedError")
        }
    }
    
    func testGetMainHolderIdentifier_WhenBuildingIdentifierThrows_ThrowError() throws
    {
        // Arrange
        let expectedError = VerifiedIdError(message: "ExpectedError", code: "expected_error")
        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: expectedError,
                                                      expectedHolderIdentifier: nil)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger:  WalletLibraryLogger(),
                                              builder: mockBuilder,
                                              storage: mockStorage)
        
        // Act / Assert
        XCTAssertThrowsError(try repository.getMainHolderIdentifier()) { error in
            
            XCTAssert(error is VerifiedIdError)
            
            guard let identifierError = error as? VerifiedIdError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "expected_error")
            XCTAssertEqual(identifierError.message, "ExpectedError")
        }
    }
    
    func testGetMainHolderIdentifier_WhenInvalidHolderIdentifierType_ThrowError() throws
    {
        // Arrange
        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: nil,
                                                      expectedHolderIdentifier: nil)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger:  WalletLibraryLogger(),
                                              builder: mockBuilder,
                                              storage: mockStorage)
        
        // Act / Assert
        XCTAssertThrowsError(try repository.getMainHolderIdentifier()) { error in
            
            XCTAssert(error is IdentifierError)
            
            guard let identifierError = error as? IdentifierError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "identifier_type_not_supported")
            XCTAssertEqual(identifierError.message, "Identifier type not supported: MockHolderIdentifier.")
        }
    }
    
    func testGetMainHolderIdentifier_WhenStoringNewHolderIdentifierThrows_ThrowError() throws
    {
        // Arrange
        let keychainIdentifier = KeychainIdentifier(id: "mockId",
                                                    algorithm: "mockAlgorithm",
                                                    method: "mockMethod",
                                                    keyReference: "mockKeyReference",
                                                    keyReferenceSecret: MockCryptoSecret(id: UUID()),
                                                    cryptoOperations: MockCryptoOperations())
        let expectedError = VerifiedIdError(message: "ExpectedError", code: "expected_error")
        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: nil,
                                                      expectedHolderIdentifier: keychainIdentifier)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: expectedError,
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger:  WalletLibraryLogger(),
                                              builder: mockBuilder,
                                              storage: mockStorage)
        
        // Act / Assert
        XCTAssertThrowsError(try repository.getMainHolderIdentifier()) { error in
            
            XCTAssert(error is VerifiedIdError)
            
            guard let identifierError = error as? VerifiedIdError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "expected_error")
            XCTAssertEqual(identifierError.message, "ExpectedError")
        }
    }
    
    func testGetMainHolderIdentifier_WhenMissingDidMethodProperty_ThrowError() throws
    {
        // Arrange
        let keyId = UUID()
        let mockProperties = MockStoredHolderIdentifierProperties(keyId: keyId,
                                                                  didMethod: nil,
                                                                  algorithm: "mockAlgorithm",
                                                                  keyReference: "mockKeyReference")
        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: nil,
                                                      expectedHolderIdentifier: nil)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedHolderIdentifierProperties: [mockProperties],
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger:  WalletLibraryLogger(),
                                              builder: mockBuilder,
                                              storage: mockStorage)
        
        // Act / Assert
        XCTAssertThrowsError(try repository.getMainHolderIdentifier()) { error in
            
            XCTAssert(error is VerifiedIdError)
            
            guard let identifierError = error as? VerifiedIdError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "property_not_present")
            XCTAssertEqual(identifierError.message, "Property Not Present: didMethod.")
        }
    }
    
    func testGetMainHolderIdentifier_WhenMissingKeyIdProperty_ThrowError() throws
    {
        // Arrange
        let mockProperties = MockStoredHolderIdentifierProperties(keyId: nil,
                                                                  didMethod: "mockDidMethod",
                                                                  algorithm: "mockAlgorithm",
                                                                  keyReference: "mockKeyReference")
        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: nil,
                                                      expectedHolderIdentifier: nil)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedHolderIdentifierProperties: [mockProperties],
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger:  WalletLibraryLogger(),
                                              builder: mockBuilder,
                                              storage: mockStorage)
        
        // Act / Assert
        XCTAssertThrowsError(try repository.getMainHolderIdentifier()) { error in
            
            XCTAssert(error is VerifiedIdError)
            
            guard let identifierError = error as? VerifiedIdError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "property_not_present")
            XCTAssertEqual(identifierError.message, "Property Not Present: KeyId.")
            
        }
    }
    
    func testGetMainHolderIdentifier_WhenMissingAlgorithmProperty_ThrowError() throws
    {
        // Arrange
        let keyId = UUID()
        let mockProperties = MockStoredHolderIdentifierProperties(keyId: keyId,
                                                                  didMethod: "mockDidMethod",
                                                                  algorithm: nil,
                                                                  keyReference: "mockKeyReference")
        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: nil,
                                                      expectedHolderIdentifier: nil)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedHolderIdentifierProperties: [mockProperties],
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger: WalletLibraryLogger(), builder: mockBuilder,
                                              storage: mockStorage)
        
        // Act / Assert
        XCTAssertThrowsError(try repository.getMainHolderIdentifier()) { error in
            
            XCTAssert(error is VerifiedIdError)
            
            guard let identifierError = error as? VerifiedIdError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "property_not_present")
            XCTAssertEqual(identifierError.message, "Property Not Present: algorithm.")
            
        }
    }
    
    func testGetMainHolderIdentifier_WhenMissingKeyReferenceProperty_ThrowError() throws
    {
        // Arrange
        let keyId = UUID()
        let mockProperties = MockStoredHolderIdentifierProperties(keyId: keyId,
                                                                  didMethod: "mockDidMethod",
                                                                  algorithm: "mockAlgorithm",
                                                                  keyReference: nil)
        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: nil,
                                                      expectedHolderIdentifier: nil)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedHolderIdentifierProperties: [mockProperties],
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger:  WalletLibraryLogger(),
                                              builder: mockBuilder,
                                              storage: mockStorage)
        
        // Act / Assert
        XCTAssertThrowsError(try repository.getMainHolderIdentifier()) { error in

            XCTAssert(error is VerifiedIdError)
            
            guard let identifierError = error as? VerifiedIdError else
            {
                XCTFail()
                return
            }
            
            XCTAssertEqual(identifierError.code, "property_not_present")
            XCTAssertEqual(identifierError.message, "Property Not Present: keyReference.")
            
        }
    }
    
    func testGetMainHolderIdentifier_WhenCreatingNewHolder_ReturnsHolderIdentifier() throws
    {
        // Arrange
        let keychainIdentifier = KeychainIdentifier(id: "mockId",
                                                    algorithm: "mockAlgorithm",
                                                    method: "mockMethod",
                                                    keyReference: "mockKeyReference",
                                                    keyReferenceSecret: MockCryptoSecret(id: UUID()),
                                                    cryptoOperations: MockCryptoOperations())

        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: nil,
                                                      expectedHolderIdentifier: keychainIdentifier)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger:  WalletLibraryLogger(),
                                              builder: mockBuilder,
                                              storage: mockStorage)
        
        // Act
        let result = try repository.getMainHolderIdentifier()
        
        // Assert
        XCTAssert(result is KeychainIdentifier)
        XCTAssertEqual(result.id, keychainIdentifier.id)
        XCTAssertEqual(result.algorithm, keychainIdentifier.algorithm)
        XCTAssertEqual(result.keyReference, keychainIdentifier.keyReference)
        XCTAssertEqual(result.method, keychainIdentifier.method)
    }
    
    func testGetMainHolderIdentifier_WhenValidInputsStoredInStorage_ReturnsHolderIdentifier() throws
    {
        // Arrange
        let keyId = UUID()
        let mockProperties = MockStoredHolderIdentifierProperties(keyId: keyId,
                                                                  didMethod: "mockDidMethod",
                                                                  algorithm: "mockAlgorithm",
                                                                  keyReference: "mockKeyReference")
        let keychainIdentifier = KeychainIdentifier(id: "mockId",
                                                    algorithm: "mockAlgorithm",
                                                    method: "mockMethod",
                                                    keyReference: "mockKeyReference",
                                                    keyReferenceSecret: MockCryptoSecret(id: UUID()),
                                                    cryptoOperations: MockCryptoOperations())

        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: nil,
                                                      expectedHolderIdentifier: keychainIdentifier)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedHolderIdentifierProperties: [mockProperties],
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger:  WalletLibraryLogger(),
                                              builder: mockBuilder,
                                              storage: mockStorage)
        
        // Act
        let result = try repository.getMainHolderIdentifier()
        
        // Assert
        XCTAssert(result is KeychainIdentifier)
        XCTAssertEqual(result.id, keychainIdentifier.id)
        XCTAssertEqual(result.algorithm, keychainIdentifier.algorithm)
        XCTAssertEqual(result.keyReference, keychainIdentifier.keyReference)
        XCTAssertEqual(result.method, keychainIdentifier.method)
    }
    
    func testPruneHolderIdentifiers_WhenNoCredentialsExist_DoesNotThrow()
    {
        // Arrange
        let keyId = UUID()

        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: nil,
                                                      expectedHolderIdentifier: nil)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedHolderIdentifierProperties: [],
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger:  WalletLibraryLogger(),
                                              builder: mockBuilder,
                                              storage: mockStorage)
        
        do
        {
            // Act
            try repository.pruneHolderIdentifiers()
        }
        catch
        {
            // Assert
            XCTFail("Expected not to throw")
        }
    }
    
    func testPruneHolderIdentifiers_WhenIdentifierExists_DoesNotPrune()
    {
        // Arrange
        let keyId = UUID()
        let mockProperties = MockStoredHolderIdentifierProperties(keyId: keyId,
                                                                  didMethod: "mockDidMethod",
                                                                  algorithm: "mockAlgorithm",
                                                                  keyReference: "mockKeyReference")
        let keychainIdentifier = KeychainIdentifier(id: "mockId",
                                                    algorithm: "mockAlgorithm",
                                                    method: "mockMethod",
                                                    keyReference: "mockKeyReference",
                                                    keyReferenceSecret: MockCryptoSecret(id: UUID()),
                                                    cryptoOperations: MockCryptoOperations())

        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: nil,
                                                      expectedHolderIdentifier: keychainIdentifier)
        
        let failureException = VerifiedIdError(message: "Not expected to delete", code: "test_failed")
        
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedHolderIdentifierProperties: [mockProperties],
                                                      expectedErrorToThrowForDeleting: failureException)
        
        let repository = IdentifierRepository(logger:  WalletLibraryLogger(),
                                              builder: mockBuilder,
                                              storage: mockStorage)
        
        do
        {
            // Act
            try repository.pruneHolderIdentifiers()
        }
        catch
        {
            // Assert
            XCTFail("Expected not to throw")
        }
    }
    
    func testPruneHolderIdentifiers_WhenIdentifierMissingCrypto_Prunes()
    {
        // Arrange
        let keyId = UUID()
        let mockProperties = MockStoredHolderIdentifierProperties(keyId: keyId,
                                                                  didMethod: "mockDidMethod",
                                                                  algorithm: "mockAlgorithm",
                                                                  keyReference: "mockKeyReference")
        

        let mockBuilder = MockHolderIdentifierBuilder(expectedErrorToThrow: SecretStoringError.itemNotFound,
                                                      expectedHolderIdentifier: nil)
        let mockStorage = MockHolderIdentifierStorage(expectedErrorToThrowForFetching: nil,
                                                      expectedErrorToThrowForStoring: nil,
                                                      expectedHolderIdentifierProperties: [mockProperties],
                                                      expectedErrorToThrowForDeleting: nil)
        
        let repository = IdentifierRepository(logger:  WalletLibraryLogger(),
                                              builder: mockBuilder,
                                              storage: mockStorage)
        
        do
        {
            // Act
            try repository.pruneHolderIdentifiers()
        }
        catch
        {
            // Assert
            XCTFail("Expected not to throw")
        }
    }
}

struct MockStoredHolderIdentifierProperties: HolderIdentifierStoredProperties
{
    let id: String?
    
    let keyId: UUID?
    
    let didMethod: String?
    
    let algorithm: String?
    
    let keyReference: String?
    
    init(id: String? = nil,
         keyId: UUID?,
         didMethod: String?,
         algorithm: String?,
         keyReference: String?)
    {
        self.id = id
        self.keyId = keyId
        self.didMethod = didMethod
        self.algorithm = algorithm
        self.keyReference = keyReference
    }
}
