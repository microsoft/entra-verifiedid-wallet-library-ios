/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class Random32BytesSecretTests: XCTestCase {
    
    func testNewSecret() throws {
        let store = SecretStoreMock()
        let secret = try Random32BytesSecret(withStore: store)
        
        let value = try store.getSecret(id: secret.id, itemTypeCode: Random32BytesSecret.itemTypeCode, accessGroup: nil)
        XCTAssertTrue(value.count == 32)
    }

    // COMMENTING OUT UNTIL IDENTIFIER IS IMPLEMENTED
//    func testNewSecretsAreDifferent() throws {
//        let store = SecretStoreMock()
//        let secret1 = Random32BytesSecret(withStore: store)!
//        let secret2 = Random32BytesSecret(withStore: store)!
//
//        let value1 = try store.getSecret(id: secret1.id, itemTypeCode: Random32BytesSecret.itemTypeCode)
//        let value2 = try store.getSecret(id: secret2.id, itemTypeCode: Random32BytesSecret.itemTypeCode)
//        XCTAssertNotEqual(value1, value2)
//    }
    
    func testWithUnsafeBytesValueMatchStoredOne() throws {
        let store = SecretStoreMock()
        let secret = try Random32BytesSecret(withStore: store)
        try secret.withUnsafeBytes { (valuePtr) in
            let val = Data(valuePtr)
            XCTAssertEqual(val, try store.getSecret(id: secret.id, itemTypeCode: Random32BytesSecret.itemTypeCode, accessGroup: nil))
        }
    }

    func testSameGroupMigrationValidatesMissingAndMalformedKeys() throws {
        let store = MigrationSecretStore()
        let secret = Random32BytesSecret(withStore: store, andId: UUID())
        XCTAssertThrowsError(try secret.migrateKey(fromAccessGroup: nil))
        store.values["source"] = Data(repeating: 1, count: 31)
        XCTAssertThrowsError(try secret.migrateKey(fromAccessGroup: nil))
        XCTAssertEqual(store.saveCount, 0)
        XCTAssertEqual(store.deleteCount, 0)
    }

    func testMigrationCopiesVerifiesAndRetriesWithoutDeletingSource() throws {
        let store = MigrationSecretStore()
        store.values["source"] = Data(repeating: 1, count: 32)
        let secret = Random32BytesSecret(withStore: store, andId: UUID(), inAccessGroup: "destination")
        try secret.migrateKey(fromAccessGroup: nil)
        try secret.migrateKey(fromAccessGroup: nil)
        XCTAssertTrue(store.values["source"] == store.values["destination"])
        XCTAssertEqual(store.saveCount, 1)
        XCTAssertEqual(store.deleteCount, 0)

        store.values.removeValue(forKey: "source")
        try secret.migrateKey(fromAccessGroup: nil)
        XCTAssertEqual(store.saveCount, 1)
    }

    func testConflictingDestinationIsNotOverwritten() throws {
        let store = MigrationSecretStore()
        store.values["source"] = Data(repeating: 1, count: 32)
        store.values["destination"] = Data(repeating: 2, count: 32)
        let before = store.values
        let secret = Random32BytesSecret(withStore: store, andId: UUID(), inAccessGroup: "destination")
        XCTAssertThrowsError(try secret.migrateKey(fromAccessGroup: nil))
        XCTAssertTrue(before == store.values)
        XCTAssertEqual(store.saveCount, 0)
        XCTAssertEqual(store.deleteCount, 0)
    }

    func testDestinationSaveFailurePreservesSourceAndCanRetry() throws {
        let store = MigrationSecretStore()
        store.values["source"] = Data(repeating: 1, count: 32)
        store.saveError = SecretStoringError.saveToStoreError(status: errSecInteractionNotAllowed)
        let secret = Random32BytesSecret(withStore: store, andId: UUID(), inAccessGroup: "destination")
        XCTAssertThrowsError(try secret.migrateKey(fromAccessGroup: nil)) { error in
            guard case SecretStoringError.saveToStoreError(status: errSecInteractionNotAllowed, message: _) = error else {
                return XCTFail("Expected original save status")
            }
        }
        XCTAssertNotNil(store.values["source"])
        XCTAssertNil(store.values["destination"])
        XCTAssertEqual(store.deleteCount, 0)
        store.saveError = nil
        try secret.migrateKey(fromAccessGroup: nil)
        XCTAssertTrue(store.values["source"] == store.values["destination"])
    }

    func testTransientReadErrorsNeverSaveOrDelete() throws {
        for group in ["source", "destination"] {
            let store = MigrationSecretStore()
            store.values["source"] = Data(repeating: 1, count: 32)
            store.readErrorGroup = group
            let secret = Random32BytesSecret(withStore: store, andId: UUID(), inAccessGroup: "destination")
            XCTAssertThrowsError(try secret.migrateKey(fromAccessGroup: nil)) { error in
                guard case SecretStoringError.readFromStoreError(status: errSecInteractionNotAllowed, message: _) = error else {
                    return XCTFail("Expected original read status")
                }
            }
            XCTAssertNotNil(store.values["source"])
            XCTAssertEqual(store.saveCount, 0)
            XCTAssertEqual(store.deleteCount, 0)
        }
    }

    func testPostSaveVerificationFailurePreservesSource() throws {
        let store = MigrationSecretStore()
        store.values["source"] = Data(repeating: 1, count: 32)
        store.failReadAfterSave = true
        let secret = Random32BytesSecret(withStore: store, andId: UUID(), inAccessGroup: "destination")
        XCTAssertThrowsError(try secret.migrateKey(fromAccessGroup: nil))
        XCTAssertTrue(store.values["source"] == store.values["destination"])
        XCTAssertEqual(store.deleteCount, 0)
        store.readErrorGroup = nil
        try secret.migrateKey(fromAccessGroup: nil)
        XCTAssertEqual(store.saveCount, 1)
    }

    func testDuplicateSaveRaceVerifiesInsteadOfOverwriting() throws {
        for conflicting in [false, true] {
            let store = MigrationSecretStore()
            store.values["source"] = Data(repeating: 1, count: 32)
            store.racingDestination = Data(repeating: conflicting ? 2 : 1, count: 32)
            let secret = Random32BytesSecret(withStore: store, andId: UUID(), inAccessGroup: "destination")
            if conflicting {
                XCTAssertThrowsError(try secret.migrateKey(fromAccessGroup: nil))
            } else {
                try secret.migrateKey(fromAccessGroup: nil)
            }
            XCTAssertNotNil(store.values["source"])
            XCTAssertEqual(store.deleteCount, 0)
        }
    }
}

private final class MigrationSecretStore: SecretStoring {
    var values: [String: Data] = [:]
    var saveError: Error?
    var readErrorGroup: String?
    var failReadAfterSave = false
    var racingDestination: Data?
    var saveCount = 0
    var deleteCount = 0

    func getSecret(id: UUID, itemTypeCode: String, accessGroup: String?) throws -> Data {
        let group = accessGroup ?? "source"
        if readErrorGroup == group {
            throw SecretStoringError.readFromStoreError(status: errSecInteractionNotAllowed)
        }
        guard let value = values[group] else { throw SecretStoringError.itemNotFound }
        return value
    }

    func saveSecret(id: UUID, itemTypeCode: String, accessGroup: String?, value: inout Data) throws {
        saveCount += 1
        defer { value.resetBytes(in: 0..<value.count) }
        if let error = saveError { throw error }
        let group = accessGroup ?? "source"
        if let racingDestination = racingDestination {
            values[group] = racingDestination
            throw SecretStoringError.saveToStoreError(status: errSecDuplicateItem)
        }
        guard values[group] == nil else { throw SecretStoringError.itemAlreadyInStore }
        values[group] = value
        if failReadAfterSave { readErrorGroup = group }
    }

    func deleteSecret(id: UUID, itemTypeCode: String, accessGroup: String?) throws {
        deleteCount += 1
        values.removeValue(forKey: accessGroup ?? "source")
    }
}
