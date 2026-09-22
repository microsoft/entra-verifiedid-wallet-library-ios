/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation


import XCTest
@testable import WalletLibrary

class KeychainSecretStoreTests: XCTestCase {
    
    func testSaveAndRetrieve() throws {
        var secret = Data(repeating: 1, count: 32)
        let secretCopy = Data(secret)
        let store = KeychainSecretStore()
        let secretId = UUID()
        try store.saveSecret(id: secretId, itemTypeCode: "ABCD", value: &secret)
        let retreivedSecret = try store.getSecret(id: secretId, itemTypeCode: "ABCD", accessGroup: nil)
        XCTAssertEqual(secretCopy, retreivedSecret)
    }
    
    func testSaveAndRetrieveAsDifferentType() throws {
        let secretId : UUID = UUID()
        let store = KeychainSecretStore()
        var value = Data(repeating: 1, count: 32)
        try store.saveSecret(id: secretId, itemTypeCode: "ABCD", value: &value)
        do {
            let _ = try store.getSecret(id: secretId, itemTypeCode: "AAAA", accessGroup: nil)
            XCTAssertTrue(false)
        } catch SecretStoringError.itemNotFound {
            // We expect an exception for this case.
        }
    }

    func testMigrationUsesPersistentReferenceAndPreservesProtectionAttributes() throws {
        let keychain = MigrationKeychain()
        let store = keychain.store()
        try store.migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: nil, toAccessGroup: "destination")
        XCTAssertEqual(keychain.updateCount, 1)
        XCTAssertEqual(keychain.sourceGroup, "destination")
        XCTAssertTrue(keychain.destination == keychain.value)
        XCTAssertNil(keychain.discoveryQuery?[kSecAttrAccessGroup as String])
        XCTAssertEqual(keychain.updateQuery?[kSecAttrAccessGroup as String] as? String, "source")
        XCTAssertTrue(keychain.updateQuery?[kSecValuePersistentRef as String] as? Data == keychain.reference)
        XCTAssertEqual(Set(keychain.updatedAttributes?.keys.map { $0 } ?? []), [kSecAttrAccessGroup as String])
        XCTAssertEqual(keychain.updatedAttributes?[kSecAttrAccessGroup as String] as? String, "destination")
        XCTAssertNil(keychain.updateQuery?[kSecReturnData as String])
        XCTAssertNil(keychain.updateQuery?[kSecReturnAttributes as String])

        try store.migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: nil, toAccessGroup: "destination")
        XCTAssertEqual(keychain.updateCount, 1)
    }

    func testExistingDestinationMustMatchAndSourceIsRetained() throws {
        for conflicting in [false, true] {
            let keychain = MigrationKeychain()
            keychain.destination = Data(repeating: conflicting ? 2 : 1, count: 32)
            if conflicting {
                XCTAssertThrowsError(try keychain.store().migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: nil, toAccessGroup: "destination"))
            } else {
                try keychain.store().migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: nil, toAccessGroup: "destination")
            }
            XCTAssertEqual(keychain.updateCount, 0)
            XCTAssertEqual(keychain.sourceGroup, "source")
        }
    }

    func testAmbiguousNilGroupSourceIsNotMoved() {
        let keychain = MigrationKeychain()
        keychain.ambiguousSource = true
        XCTAssertThrowsError(try keychain.store().migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: nil, toAccessGroup: "destination"))
        XCTAssertEqual(keychain.updateCount, 0)
    }

    func testDiscoveryAndDestinationReadErrorsArePreserved() {
        for discovery in [true, false] {
            let keychain = MigrationKeychain()
            if discovery {
                keychain.discoveryStatus = errSecInteractionNotAllowed
            } else {
                keychain.readStatus = errSecInteractionNotAllowed
            }
            XCTAssertThrowsError(try keychain.store().migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: nil, toAccessGroup: "destination")) { error in
                guard case SecretStoringError.readFromStoreError(status: errSecInteractionNotAllowed, message: _) = error else {
                    return XCTFail("Expected original read status")
                }
            }
            XCTAssertEqual(keychain.updateCount, 0)
            XCTAssertEqual(keychain.sourceGroup, "source")
        }
    }

    func testFailedUpdateRetainsSourceAndRetrySucceeds() throws {
        let keychain = MigrationKeychain()
        keychain.updateStatus = errSecMissingEntitlement
        let store = keychain.store()
        XCTAssertThrowsError(try store.migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: "source", toAccessGroup: "destination")) { error in
            guard case SecretStoringError.saveToStoreError(status: errSecMissingEntitlement, message: _) = error else {
                return XCTFail("Expected original update status")
            }
        }
        XCTAssertEqual(keychain.sourceGroup, "source")
        XCTAssertNil(keychain.destination)
        keychain.updateStatus = errSecSuccess
        try store.migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: "source", toAccessGroup: "destination")
        XCTAssertTrue(keychain.destination == keychain.value)
    }

    func testVerificationFailureAfterMoveCanBeRetried() throws {
        let keychain = MigrationKeychain()
        keychain.failVerification = true
        let store = keychain.store()
        XCTAssertThrowsError(try store.migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: "source", toAccessGroup: "destination"))
        XCTAssertTrue(keychain.destination == keychain.value)
        keychain.readStatus = errSecSuccess
        try store.migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: "source", toAccessGroup: "destination")
        XCTAssertEqual(keychain.updateCount, 1)
    }

    func testRacingDestinationMustMatchAfterDuplicateOrMissingUpdate() throws {
        for status in [errSecDuplicateItem, errSecItemNotFound] {
            for conflicting in [false, true] {
                let keychain = MigrationKeychain()
                keychain.updateStatus = status
                keychain.racingDestination = Data(repeating: conflicting ? 2 : 1, count: 32)
                if conflicting {
                    XCTAssertThrowsError(try keychain.store().migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: nil, toAccessGroup: "destination"))
                } else {
                    try keychain.store().migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: nil, toAccessGroup: "destination")
                }
                XCTAssertEqual(keychain.sourceGroup, "source")
            }
        }
    }

    func testUnknownDefaultDestinationFailsWithoutUpdate() {
        let keychain = MigrationKeychain()
        XCTAssertThrowsError(try keychain.store().migrateSecret(id: UUID(), itemTypeCode: "r32B", fromAccessGroup: "source", toAccessGroup: nil))
        XCTAssertEqual(keychain.updateCount, 0)
    }
}

private final class MigrationKeychain {
    let value = Data(repeating: 1, count: 32)
    let reference = Data([1, 2, 3])
    var sourceGroup = "source"
    var destination: Data?
    var ambiguousSource = false
    var discoveryStatus = errSecSuccess
    var readStatus = errSecSuccess
    var updateStatus = errSecSuccess
    var failVerification = false
    var racingDestination: Data?
    var updateCount = 0
    var discoveryQuery: [String: Any]?
    var updateQuery: [String: Any]?
    var updatedAttributes: [String: Any]?

    func store() -> KeychainSecretStore {
        KeychainSecretStore(copyMatching: { query, result in
            guard let query = query as NSDictionary as? [String: Any] else {
                XCTFail("Expected string keychain query keys")
                return errSecParam
            }
            if query[kSecReturnAttributes as String] as? Bool == true {
                self.discoveryQuery = query
                guard self.discoveryStatus == errSecSuccess else { return self.discoveryStatus }
                if let group = query[kSecAttrAccessGroup as String] as? String, group != self.sourceGroup {
                    return errSecItemNotFound
                }
                var items: [[String: Any]] = [[kSecAttrAccessGroup as String: self.sourceGroup,
                                              kSecValuePersistentRef as String: self.reference,
                                              kSecValueData as String: self.value,
                                              kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]]
                if self.ambiguousSource {
                    items.append([kSecAttrAccessGroup as String: "anotherSource",
                                  kSecValuePersistentRef as String: Data([4]),
                                  kSecValueData as String: self.value])
                }
                result?.pointee = items as CFArray
                return errSecSuccess
            }
            guard self.readStatus == errSecSuccess else { return self.readStatus }
            guard let value = self.destination else { return errSecItemNotFound }
            result?.pointee = value as CFData
            return errSecSuccess
        }, update: { query, attributes in
            self.updateCount += 1
            self.updateQuery = query as NSDictionary as? [String: Any]
            self.updatedAttributes = attributes as NSDictionary as? [String: Any]
            if self.updateStatus == errSecSuccess {
                self.sourceGroup = "destination"
                self.destination = self.value
            } else if let racingDestination = self.racingDestination {
                self.destination = racingDestination
            }
            if self.failVerification { self.readStatus = errSecInteractionNotAllowed }
            return self.updateStatus
        })
    }
}
