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
    public var id: UUID
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
        _ = try self.store.getSecret(id: id, itemTypeCode: Random32BytesSecret.itemTypeCode, accessGroup: accessGroup)
    }
    
    func migrateKey(fromAccessGroup currentAccessGroup: String?) throws {
        
        /// If old access group is equal to new access group, no action required.
        if currentAccessGroup == accessGroup {
            return
        }
        
        var value = try self.store.getSecret(id: id,
                                             itemTypeCode: Random32BytesSecret.itemTypeCode,
                                             accessGroup: currentAccessGroup)
        defer {
            let secretSize = value.count
            value.withUnsafeMutableBytes { (secretPtr) in
                memset_s(secretPtr.baseAddress, secretSize, 0, secretSize)
                return
            }
        }
        
        /// Delete from old access group
        try self.store.deleteSecret(id: id,
                                    itemTypeCode: Random32BytesSecret.itemTypeCode,
                                    accessGroup: currentAccessGroup)
        
        /// Save to new access group
        try self.store.saveSecret(id: id,
                                  itemTypeCode: Random32BytesSecret.itemTypeCode,
                                  accessGroup: accessGroup,
                                  value: &value)
    }
}
