/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

final class Random32BytesSecret: Secret {

    private enum Random32BytesSecretError: Error {
        case secRandomCopyBytesFailed(status: OSStatus)
    }

    static var itemTypeCode: String = "r32B"
    var id: UUID
    private let store: SecretStoring
    let accessGroup: String?
    
    init(withStore store: SecretStoring, andId id: UUID, inAccessGroup accessGroup: String? = nil) {
        self.id = id
        self.store = store
        self.accessGroup = accessGroup
    }
    
    init(withStore store: SecretStoring, inAccessGroup accessGroup: String? = nil) throws {
        self.store = store
        self.accessGroup = accessGroup
        
        var value = Data(count: 32)
        defer {
            let secretSize = value.count
            value.withUnsafeMutableBytes { (secretPtr) in
                memset_s(secretPtr.baseAddress, secretSize, 0, secretSize)
                return
            }
        }
        
        let result = value.withUnsafeMutableBytes { (secretPtr) in
            SecRandomCopyBytes(kSecRandomDefault, secretPtr.count, secretPtr.baseAddress!)
        }
        
        guard result == errSecSuccess else {
            throw Random32BytesSecretError.secRandomCopyBytesFailed(status: result)
        }
        id = UUID()

        try self.store.saveSecret(id: id, itemTypeCode: Random32BytesSecret.itemTypeCode, accessGroup: accessGroup, value: &value)
    }
    
    func withUnsafeBytes(_ body: (UnsafeRawBufferPointer) throws -> Void) throws {
        var value = try self.store.getSecret(id: id, itemTypeCode: Random32BytesSecret.itemTypeCode, accessGroup: accessGroup)
        defer {
            let secretSize = value.count
            value.withUnsafeMutableBytes { (secretPtr) in
                memset_s(secretPtr.baseAddress, secretSize, 0, secretSize)
                return
            }
        }
        
        try value.withUnsafeBytes { (valuePtr) in
            try body(valuePtr)
        }
    }
    
    func isValidKey() throws {
        try withUnsafeBytes { bytes in
            guard bytes.count == 32 else { throw SecretStoringError.invalidItemInStore }
        }
    }
    
    func migrateKey(fromAccessGroup currentAccessGroup: String?) throws {
        
        if currentAccessGroup == accessGroup {
            try isValidKey()
            return
        }

        if let migratingStore = store as? SecretMigrating {
            try migratingStore.migrateSecret(id: id,
                                             itemTypeCode: Self.itemTypeCode,
                                             fromAccessGroup: currentAccessGroup,
                                             toAccessGroup: accessGroup)
            try isValidKey()
            return
        }
        
        var value: Data
        do {
            value = try store.getSecret(id: id, itemTypeCode: Self.itemTypeCode, accessGroup: currentAccessGroup)
        } catch SecretStoringError.itemNotFound {
            // A previous attempt may already have moved this key.
            try isValidKey()
            return
        }
        defer {
            let secretSize = value.count
            value.withUnsafeMutableBytes { (secretPtr) in
                memset_s(secretPtr.baseAddress, secretSize, 0, secretSize)
                return
            }
        }
        
        guard value.count == 32 else { throw SecretStoringError.invalidItemInStore }

        do {
            try verifyStoredValue(value)
            return
        } catch SecretStoringError.itemNotFound {
            // Only confirmed absence permits adding the destination.
        }
        
        var copy = value
        defer { copy.resetBytes(in: 0..<copy.count) }
        do {
            try store.saveSecret(id: id, itemTypeCode: Self.itemTypeCode, accessGroup: accessGroup, value: &copy)
        } catch SecretStoringError.itemAlreadyInStore {
            // Another attempt may have added the same key; verify rather than overwrite.
        } catch SecretStoringError.saveToStoreError(status: errSecDuplicateItem, message: _) {
            // Keychain-backed custom stores may return the OS status directly.
        }
        try verifyStoredValue(value)
        // SecretStoring cannot identify the actual group of a nil-group source.
        // Retain it rather than risk deleting the verified destination.
    }

    private func verifyStoredValue(_ expected: Data) throws {
        try withUnsafeBytes { bytes in
            guard Data(bytes) == expected else { throw SecretStoringError.invalidItemInStore }
        }
    }
}
