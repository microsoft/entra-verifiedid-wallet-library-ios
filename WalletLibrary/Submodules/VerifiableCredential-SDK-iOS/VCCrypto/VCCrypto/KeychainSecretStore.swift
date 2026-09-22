/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

struct KeychainSecretStore: SecretStoring, SecretMigrating {
    
    private let vcService = "com.microsoft.vcCrypto"
    private let copyMatching: (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus
    private let update: (CFDictionary, CFDictionary) -> OSStatus

    init(copyMatching: @escaping (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = SecItemCopyMatching,
         update: @escaping (CFDictionary, CFDictionary) -> OSStatus = SecItemUpdate) {
        self.copyMatching = copyMatching
        self.update = update
    }

    func migrateSecret(id: UUID, itemTypeCode: String, fromAccessGroup: String?, toAccessGroup: String?) throws {
        guard let destinationGroup = toAccessGroup, !destinationGroup.isEmpty else {
            throw SecretStoringError.readFromStoreError(status: errSecParam,
                                                        message: "Migration requires an explicit destination access group.")
        }
        var query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: id.uuidString,
                     kSecAttrService: vcService,
                     kSecAttrType: itemTypeCode,
                     kSecMatchLimit: kSecMatchLimitAll,
                     kSecReturnAttributes: true,
                     kSecReturnPersistentRef: true,
                     kSecReturnData: true] as [String: Any]
        if let group = fromAccessGroup {
            query[kSecAttrAccessGroup as String] = group
        }
        var result: CFTypeRef?
        let status = copyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            _ = try getSecret(id: id, itemTypeCode: itemTypeCode, accessGroup: destinationGroup)
            return
        }
        guard status == errSecSuccess else {
            throw SecretStoringError.readFromStoreError(status: status)
        }
        guard let items = result as? [[String: Any]],
              items.allSatisfy({ $0[kSecAttrAccessGroup as String] is String }) else {
            throw SecretStoringError.invalidItemInStore
        }
        let sources = items.filter { $0[kSecAttrAccessGroup as String] as? String != destinationGroup }
        guard !sources.isEmpty else {
            _ = try getSecret(id: id, itemTypeCode: itemTypeCode, accessGroup: destinationGroup)
            return
        }
        // A nil-group query spans every entitled group; never choose an arbitrary source.
        guard sources.count == 1,
              let source = sources.first,
              let sourceGroup = source[kSecAttrAccessGroup as String] as? String,
              let reference = source[kSecValuePersistentRef as String] as? Data,
              var value = source[kSecValueData as String] as? Data,
              value.count == 32 else {
            throw SecretStoringError.invalidItemInStore
        }
        defer { value.resetBytes(in: 0..<value.count) }
        do {
            try verifySecret(id: id, itemTypeCode: itemTypeCode, accessGroup: destinationGroup, expected: value)
            return
        } catch SecretStoringError.itemNotFound {
            // Update only after confirming that no destination would be overwritten.
        }
        let sourceQuery = [kSecClass: kSecClassGenericPassword,
                           kSecValuePersistentRef: reference,
                           kSecAttrAccessGroup: sourceGroup] as [String: Any]
        let attributes = [kSecAttrAccessGroup: destinationGroup] as [String: Any]
        // In-place update preserves accessibility (including ThisDeviceOnly) and access control.
        let updateStatus = update(sourceQuery as CFDictionary, attributes as CFDictionary)
        guard updateStatus == errSecSuccess || updateStatus == errSecDuplicateItem || updateStatus == errSecItemNotFound else {
            throw SecretStoringError.saveToStoreError(status: updateStatus)
        }
        try verifySecret(id: id, itemTypeCode: itemTypeCode, accessGroup: destinationGroup, expected: value)
    }

    private func verifySecret(id: UUID, itemTypeCode: String, accessGroup: String, expected: Data) throws {
        var stored = try getSecret(id: id, itemTypeCode: itemTypeCode, accessGroup: accessGroup)
        defer { stored.resetBytes(in: 0..<stored.count) }
        guard stored == expected else { throw SecretStoringError.invalidItemInStore }
    }
    
    /// Gets the secret with the id passed in parameter
    /// - Parameters:
    ///   - id: The Id of the secret
    ///   - itemTypeCode: the item type code for the secret
    ///   - accessGroup: the access group for the secret
    /// - Returns: The secret
    func getSecret(id: UUID, itemTypeCode: String, accessGroup: String?) throws -> Data {
        
        var query: [String: Any]
        if let accessGroup = accessGroup
        {
            query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: id.uuidString,
                     kSecAttrService: vcService,
                     kSecAttrType: itemTypeCode,
                     kSecAttrAccessGroup: accessGroup,
                     kSecReturnData: true] as [String: Any]
        }
        else
        {
            query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: id.uuidString,
                     kSecAttrService: vcService,
                     kSecAttrType: itemTypeCode,
                     kSecReturnData: true] as [String: Any]
        }
        
        var item: CFTypeRef?
        let status = copyMatching(query as CFDictionary, &item)
        
        var statusMessage: String? = nil
        if #available(iOS 11.3, *) {
            statusMessage = SecCopyErrorMessageString(status, nil) as? String
        }
        
        guard status != errSecItemNotFound else { throw SecretStoringError.itemNotFound }
        
        guard status == errSecSuccess else {
            throw SecretStoringError.readFromStoreError(status: status as OSStatus, message: statusMessage)
        }
        
        guard var value = item as? Data else { throw SecretStoringError.invalidItemInStore }
        defer {
            let secretSize = value.count
            value.withUnsafeMutableBytes { (secretPtr) in
                memset_s(secretPtr.baseAddress, secretSize, 0, secretSize)
                return
            }
        }
        
        return value
    }
    
    /// Save the secret to keychain
    /// Note: the value passed in will be zeroed out after the secret is saved
    /// - Parameters:
    ///   - id: The Id of the secret
    ///   - itemTypeCode: The secret type code (4 chars)
    ///   - accessGroup: The access group to use to save secret.
    ///   - value: The value of the secret
    func saveSecret(id: UUID, itemTypeCode: String, accessGroup: String? = nil, value: inout Data) throws {
        defer {
            let secretSize = value.count
            value.withUnsafeMutableBytes { (secretPtr) in
                memset_s(secretPtr.baseAddress, secretSize, 0, secretSize)
                return
            }
        }
        
        guard itemTypeCode.count == 4 else { throw SecretStoringError.invalidType }
        
        // kSecAttrAccount is used to store the secret Id so that we can look it up later
        // kSecAttrService is always set to vcService to enable us to lookup all our secrets later if needed
        // kSecAttrType is used to store the secret type to allow us to cast it to the right Type on search
        var query: [String: Any]
        if let accessGroup = accessGroup {
            query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: id.uuidString,
                     kSecAttrService: vcService,
                     kSecAttrType: itemTypeCode,
                     kSecAttrAccessGroup: accessGroup,
                     kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                     kSecValueData: value] as [String: Any]
        }
        else {
            query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: id.uuidString,
                     kSecAttrService: vcService,
                     kSecAttrType: itemTypeCode,
                     kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                     kSecValueData: value] as [String: Any]
        }
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        var statusMessage: String? = nil
        if #available(iOS 11.3, *) {
            statusMessage = SecCopyErrorMessageString(status, nil) as? String
        }
        
        guard status == errSecSuccess else {
            throw SecretStoringError.saveToStoreError(status: status, message: statusMessage)
        }
    }
    
    /// Delete the secret from keychain
    /// Note: the value passed in will be zeroed out after the secret is deleted
    /// - Parameters:
    ///   - id: The Id of the secret
    ///   - itemTypeCode: The secret type code (4 chars)
    ///   - accessGroup: The access group of the secret.
    func deleteSecret(id: UUID, itemTypeCode: String, accessGroup: String? = nil) throws {
        
        guard itemTypeCode.count == 4 else { throw SecretStoringError.invalidType }
        
        // kSecAttrAccount is used to store the secret Id so that we can look it up later
        // kSecAttrService is always set to vcService to enable us to lookup all our secrets later if needed
        // kSecAttrType is used to store the secret type to allow us to cast it to the right Type on search
        var query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: id.uuidString,
                     kSecAttrService: vcService,
                     kSecAttrType: itemTypeCode,
                     kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly] as [String: Any]
        
        if let accessGroup = accessGroup,
               accessGroup != "" {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        var statusMessage: String? = nil
        if #available(iOS 11.3, *) {
            statusMessage = SecCopyErrorMessageString(status, nil) as? String
        }
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecretStoringError.deleteFromStoreError(status: status, message: statusMessage)
        }
    }
}
