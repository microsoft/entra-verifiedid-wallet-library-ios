/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

import XCTest
@testable import VCCrypto

class KeyManagementOperationsTests: XCTestCase {
    
    let mockVCConfig = VCSDKConfigurationMock(accessGroupIdentifier: "testAccessGroup")
    
    private lazy var mockSecretStore = {
        return SecretStoreMock(testInputCallback: createTestInputCallback(expectedInputTypeCode: "r32B"))
    }()
    
    override func setUpWithError() throws {
        SecretStoreMock.wasDeleteSecretCalled = false
        SecretStoreMock.wasSaveSecretCalled = false
        SecretStoreMock.wasDeleteSecretCalled = false
        mockSecretStore.memoryStore = [:]
    }
    
    private func createTestInputCallback(expectedInputTypeCode: String) -> (String?, String?) -> () {
        return { itemTypeCode, accessGroupIdentifier in
            XCTAssertEqual(accessGroupIdentifier, self.mockVCConfig.accessGroupIdentifier)
            XCTAssertEqual(itemTypeCode, expectedInputTypeCode)
        }
    }
    
    func testSave() throws {
        let key = "testKey".data(using: .utf8)!
        let expectedItemTypeCode = String(format: "r%02dB", key.count)
        let mockSecretStore = SecretStoreMock(testInputCallback: createTestInputCallback(expectedInputTypeCode: expectedItemTypeCode))
        let operations = KeyManagementOperations(secretStore: mockSecretStore, sdkConfiguration: mockVCConfig)
        let uuid = UUID()
        try operations.save(key: key, withId: uuid)
        XCTAssertTrue(SecretStoreMock.wasSaveSecretCalled)
        XCTAssertEqual(mockSecretStore.memoryStore[uuid], key)
    }
    
    func testRetrieveKeyFromStorage() throws {
        let operations = KeyManagementOperations(secretStore: mockSecretStore, sdkConfiguration: mockVCConfig)
        let uuid = UUID()
        let keyResult = operations.retrieveKeyFromStorage(withId: uuid)
        XCTAssertEqual(mockVCConfig.accessGroupIdentifier, keyResult.accessGroup)
        XCTAssertEqual(uuid, keyResult.id)
    }
    
    func testGenerateKeyFromStorage() throws {
        let operations = KeyManagementOperations(secretStore: mockSecretStore, sdkConfiguration: mockVCConfig)
        let keyResult = try operations.generateKey()
        XCTAssertEqual(keyResult.accessGroup, mockVCConfig.accessGroupIdentifier)
        XCTAssertTrue(SecretStoreMock.wasSaveSecretCalled)
    }
    
    func testDeleteKeyFromStorage() throws {
        let operations = KeyManagementOperations(secretStore: mockSecretStore, sdkConfiguration: mockVCConfig)
        let uuid = UUID()
        let mockKey = "testKeyForDelete".data(using: .utf8)!
        mockSecretStore.memoryStore[uuid] = mockKey
        try operations.deleteKey(withId: uuid)
        XCTAssertTrue(SecretStoreMock.wasGetSecretCalled)
        XCTAssertTrue(SecretStoreMock.wasDeleteSecretCalled)
    }
    
    func testDeleteKeyFromStorageWithNoKeyFound() throws {
        let operations = KeyManagementOperations(secretStore: mockSecretStore, sdkConfiguration: mockVCConfig)
        let uuid = UUID()
        XCTAssertThrowsError(try operations.deleteKey(withId: uuid)) { error in
            XCTAssertTrue(SecretStoreMock.wasGetSecretCalled)
            XCTAssertFalse(SecretStoreMock.wasDeleteSecretCalled)
            XCTAssertEqual(error as? SecretStoreMockError, SecretStoreMockError.noKeyFound)
        }
    }
    
    func testGetKeyWithValidKey() throws {
        let operations = KeyManagementOperations(secretStore: mockSecretStore, sdkConfiguration: mockVCConfig)
        let uuid = UUID()
        let expectedKey = "testKeyForGetValidKey".data(using: .utf8)!
        mockSecretStore.memoryStore[uuid] = expectedKey
        let key = try operations.getKey(withId: uuid)
        XCTAssertTrue(SecretStoreMock.wasGetSecretCalled)
        XCTAssertEqual(key, expectedKey)
    }
    
    func testGetKeyWithNoKeyFound() throws {
        let operations = KeyManagementOperations(secretStore: mockSecretStore, sdkConfiguration: mockVCConfig)
        let uuid = UUID()
        XCTAssertThrowsError(try operations.getKey(withId: uuid)) { error in
            XCTAssertTrue(SecretStoreMock.wasGetSecretCalled)
            XCTAssertEqual(error as? SecretStoreMockError, SecretStoreMockError.noKeyFound)
        }
    }
}
