/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import CoreData
import XCTest
@testable import WalletLibrary

class IdentifierDatabaseTests: XCTestCase {
    
    let dataManager = CoreDataManager.sharedInstance
    var identifierCreator: IdentifierCreator!
    var identifierDB: IdentifierDatabase!
    
    override func setUpWithError() throws {
        let keyManagementOperations = KeyManagementOperations(sdkConfiguration: MockVCSDKConfiguration())
        identifierDB = IdentifierDatabase(keyManagementOperations: keyManagementOperations)
        try CoreDataManager.sharedInstance.deleteAllIdentifiers()
        identifierCreator = IdentifierCreator(keyManagementOperations: keyManagementOperations)
    }

    override func tearDownWithError() throws {
        try CoreDataManager.sharedInstance.deleteAllIdentifiers()
    }

    func testSavingIdentifier() throws {
        let testIdentifier = try identifierCreator.create(forId: "master", andRelyingParty: "master")
        print(testIdentifier.longFormDid)
        try identifierDB.saveIdentifier(identifier: testIdentifier)
        let fetchedIdentifier = try identifierDB.fetchMasterIdentifier()
        XCTAssertEqual(testIdentifier.longFormDid, fetchedIdentifier.longFormDid)
    }
}

class IdentifierRecoveryTests: XCTestCase {
    private var keys: RecoveryKeyOperations!
    private var database: IdentifierDatabase!
    private var service: IdentifierService!

    override func setUpWithError() throws {
        try CoreDataManager.sharedInstance.deleteAllIdentifiers()
        keys = RecoveryKeyOperations()
        database = IdentifierDatabase(keyManagementOperations: keys)
        service = IdentifierService(database: database, creator: IdentifierCreator(keyManagementOperations: keys))
    }

    override func tearDownWithError() throws {
        try CoreDataManager.sharedInstance.deleteAllIdentifiers()
    }

    func testGenuinelyAbsentMetadataCreatesOnlyOnce() throws {
        let created = try service.fetchOrCreateMasterIdentifier()
        let fetched = try service.fetchOrCreateMasterIdentifier()
        XCTAssertTrue(created.longFormDid == fetched.longFormDid)
        XCTAssertEqual(keys.generationCount, 3)
        XCTAssertEqual(keys.deleteCount, 0)
        XCTAssertEqual(try CoreDataManager.sharedInstance.fetchIdentifiers().count, 1)
    }

    func testMalformedMetadataIsNotTreatedAsAbsent() throws {
        _ = try service.fetchOrCreateMasterIdentifier()
        let model = try XCTUnwrap(CoreDataManager.sharedInstance.fetchIdentifiers().first)
        model.signingKeyId = nil
        XCTAssertThrowsError(try service.fetchOrCreateMasterIdentifier()) { error in
            guard case IdentifierDatabaseError.unableToFetchMasterIdentifier = error else {
                return XCTFail("Expected metadata error")
            }
        }
        XCTAssertEqual(keys.generationCount, 3)
        XCTAssertEqual(keys.deleteCount, 0)
        XCTAssertEqual(try CoreDataManager.sharedInstance.fetchIdentifiers().count, 1)
    }

    func testMissingMetadataAliasIsNotTreatedAsAbsent() throws {
        _ = try service.fetchOrCreateMasterIdentifier()
        let model = try XCTUnwrap(CoreDataManager.sharedInstance.fetchIdentifiers().first)
        model.alias = nil
        XCTAssertThrowsError(try service.fetchOrCreateMasterIdentifier()) { error in
            guard case IdentifierDatabaseError.noAliasSavedInIdentifierModel = error else {
                return XCTFail("Expected malformed metadata error")
            }
        }
        XCTAssertEqual(keys.generationCount, 3)
        XCTAssertEqual(keys.deleteCount, 0)
        XCTAssertEqual(try CoreDataManager.sharedInstance.fetchIdentifiers().count, 1)
    }

    func testTransientMetadataFetchErrorDoesNotCreateOrResetAndCanRetry() throws {
        let identifier = try service.fetchOrCreateMasterIdentifier()
        let failingService = MetadataFailureIdentifierService(
            database: database, creator: IdentifierCreator(keyManagementOperations: keys))
        let primary = NSError(domain: NSCocoaErrorDomain, code: NSMigrationError)
        failingService.fetchError = primary

        XCTAssertThrowsError(try failingService.fetchOrCreateMasterIdentifier()) {
            XCTAssertTrue(($0 as NSError) === primary)
        }
        try assertIdentityPreserved(identifier)
        XCTAssertTrue(keys.secrets.values.allSatisfy { $0.migrationCount == 0 })

        failingService.fetchError = nil
        let retried = try failingService.fetchOrCreateMasterIdentifier()
        XCTAssertTrue(retried.longFormDid == identifier.longFormDid)
        try assertIdentityPreserved(identifier)
    }

    func testMissingKeyAndNoOpMigrationAreRevalidatedWithoutReset() throws {
        let identifier = try service.fetchOrCreateMasterIdentifier()
        let recovery = try XCTUnwrap(keys.secrets[identifier.recoveryKey.getId()])
        recovery.validationError = SecretStoringError.itemNotFound
        recovery.migrationRepairsKey = false
        XCTAssertThrowsError(try service.fetchOrCreateMasterIdentifier()) { error in
            guard case IdentifierServiceError.keyNotFoundInKeyStore = error else {
                return XCTFail("Expected missing key after no-op migration")
            }
        }
        XCTAssertEqual(recovery.migrationCount, 1)
        try assertIdentityPreserved(identifier)
    }

    func testTransientValidationErrorPropagatesWithoutMigrationOrDeletion() throws {
        let identifier = try service.fetchOrCreateMasterIdentifier()
        let recovery = try XCTUnwrap(keys.secrets[identifier.recoveryKey.getId()])
        recovery.validationError = SecretStoringError.readFromStoreError(status: errSecInteractionNotAllowed)
        XCTAssertThrowsError(try service.fetchOrCreateMasterIdentifier()) { error in
            guard case SecretStoringError.readFromStoreError(status: errSecInteractionNotAllowed, message: _) = error else {
                return XCTFail("Expected original storage error")
            }
        }
        XCTAssertEqual(recovery.migrationCount, 0)
        try assertIdentityPreserved(identifier)
        recovery.validationError = nil
        let retried = try service.fetchOrCreateMasterIdentifier()
        XCTAssertTrue(retried.longFormDid == identifier.longFormDid)
    }

    func testPartialMigrationFailurePreservesAllKeysAndRetries() throws {
        let identifier = try service.fetchOrCreateMasterIdentifier()
        for secret in keys.secrets.values {
            secret.validationError = SecretStoringError.itemNotFound
        }
        let update = try XCTUnwrap(keys.secrets[identifier.updateKey.getId()])
        update.migrationError = SecretStoringError.saveToStoreError(status: errSecMissingEntitlement)
        XCTAssertThrowsError(try service.fetchOrCreateMasterIdentifier()) { error in
            guard case SecretStoringError.saveToStoreError(status: errSecMissingEntitlement, message: _) = error else {
                return XCTFail("Expected original migration status")
            }
        }
        XCTAssertNil(keys.secrets[identifier.recoveryKey.getId()]?.validationError)
        try assertIdentityPreserved(identifier)
        update.migrationError = nil
        let retried = try service.fetchOrCreateMasterIdentifier()
        XCTAssertTrue(retried.longFormDid == identifier.longFormDid)
        XCTAssertTrue(keys.secrets.values.allSatisfy { $0.validationError == nil })
        try assertIdentityPreserved(identifier)
    }

    func testEveryKeyIsValidatedAfterMigration() throws {
        let identifier = try service.fetchOrCreateMasterIdentifier()
        let recovery = try XCTUnwrap(keys.secrets[identifier.recoveryKey.getId()])
        let signingId = try XCTUnwrap(identifier.didDocumentKeys.first?.getId())
        let signing = try XCTUnwrap(keys.secrets[signingId])
        recovery.validationError = SecretStoringError.itemNotFound
        signing.validationError = SecretStoringError.itemNotFound
        signing.migrationRepairsKey = false
        XCTAssertThrowsError(try service.fetchOrCreateMasterIdentifier())
        XCTAssertNil(recovery.validationError)
        XCTAssertEqual(signing.migrationCount, 1)
        try assertIdentityPreserved(identifier)
    }

    func testDefaultServiceUsesFinalConfigurationAndNilResetWithoutChangingRetainedSnapshot() throws {
        let identifier = try service.fetchOrCreateMasterIdentifier()
        let oldGroup = VCSDKConfiguration.sharedInstance.accessGroupIdentifier
        let oldLog = VCSDKLog.sharedInstance
        defer {
            VCSDKConfiguration.sharedInstance.setAccessGroupIdentifier(with: oldGroup)
            VCSDKLog.sharedInstance = oldLog
        }
        VCSDKConfiguration.sharedInstance.setAccessGroupIdentifier(with: nil)
        let retained = IdentifierService()
        _ = VerifiableCredentialSDK.initialize(accessGroupIdentifier: "configured.group")
        let configured = VerifiableCredentialSDK.identifierService
        XCTAssertNil(try retained.fetchMasterIdentifier().recoveryKey.keyReference.accessGroup)
        XCTAssertEqual(try configured.fetchMasterIdentifier().updateKey.keyReference.accessGroup, "configured.group")
        _ = VerifiableCredentialSDK.initialize()
        XCTAssertNil(try VerifiableCredentialSDK.identifierService.fetchMasterIdentifier().updateKey.keyReference.accessGroup)
        XCTAssertEqual(try configured.fetchMasterIdentifier().updateKey.keyReference.accessGroup, "configured.group")
        try assertIdentityPreserved(identifier)
    }

    private func assertIdentityPreserved(_ expected: Identifier, file: StaticString = #file, line: UInt = #line) throws {
        let stored = try database.fetchMasterIdentifier()
        XCTAssertTrue(stored.longFormDid == expected.longFormDid, file: file, line: line)
        XCTAssertTrue(stored.recoveryKey.getId() == expected.recoveryKey.getId(), file: file, line: line)
        XCTAssertTrue(stored.updateKey.getId() == expected.updateKey.getId(), file: file, line: line)
        XCTAssertTrue(stored.didDocumentKeys.first?.getId() == expected.didDocumentKeys.first?.getId(), file: file, line: line)
        XCTAssertEqual(keys.generationCount, 3, file: file, line: line)
        XCTAssertEqual(keys.deleteCount, 0, file: file, line: line)
        XCTAssertEqual(keys.secrets.count, 3, file: file, line: line)
        XCTAssertEqual(try CoreDataManager.sharedInstance.fetchIdentifiers().count, 1, file: file, line: line)
    }
}

private final class MetadataFailureIdentifierService: IdentifierService {
    var fetchError: Error?

    override func fetchMasterIdentifier() throws -> Identifier {
        if let error = fetchError { throw error }
        return try super.fetchMasterIdentifier()
    }
}

private final class RecoveryKeyOperations: KeyManagementOperating {
    var secrets: [UUID: RecoverySecret] = [:]
    var generationCount = 0
    var deleteCount = 0

    func generateKey() throws -> VCCryptoSecret {
        generationCount += 1
        let secret = RecoverySecret()
        secrets[secret.id] = secret
        return secret
    }

    func retrieveKeyFromStorage(withId id: UUID) -> VCCryptoSecret {
        guard let secret = secrets[id] else {
            let missing = RecoverySecret(id: id)
            missing.validationError = SecretStoringError.itemNotFound
            return missing
        }
        return secret
    }

    func save(key: Data, withId id: UUID) throws {
        secrets[id] = RecoverySecret(id: id)
    }

    func deleteKey(withId id: UUID) throws {
        deleteCount += 1
        secrets.removeValue(forKey: id)
    }

    func getKey(withId id: UUID) throws -> Data {
        guard let secret = secrets[id] else { throw SecretStoringError.itemNotFound }
        var result = Data()
        try secret.withUnsafeBytes { result = Data($0) }
        return result
    }
}

private final class RecoverySecret: Secret {
    static let itemTypeCode = "r32B"
    let id: UUID
    let accessGroup: String? = nil
    var validationError: Error?
    var migrationError: Error?
    var migrationRepairsKey = true
    var migrationCount = 0

    init(id: UUID = UUID()) { self.id = id }

    func isValidKey() throws {
        if let error = validationError { throw error }
    }

    func migrateKey(fromAccessGroup oldAccessGroup: String?) throws {
        migrationCount += 1
        if let error = migrationError { throw error }
        if migrationRepairsKey { validationError = nil }
    }

    func withUnsafeBytes(_ body: (UnsafeRawBufferPointer) throws -> Void) throws {
        try isValidKey()
        try Data(repeating: 1, count: 32).withUnsafeBytes(body)
    }
}
