/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCCrypto
import VCToken

@testable import VCEntities

struct MockKeyManagementOperations: KeyManagementOperating {
    static let itemTypeCode = "r32b"
    static let accessGroupIdentifier = "anywhere.com.microsoft.azureauthenticator.did"
    
    static var generateKeyCallCount = 0
    let keyManagementOperations: KeyManagementOperating
    let secretStore: SecretStoring
    
    init(secretStore: SecretStoring) {
        self.secretStore = secretStore
        self.keyManagementOperations = KeyManagementOperations(secretStore: secretStore, sdkConfiguration: VCSDKConfiguration.sharedInstance)
    }
    
    func generateKey() throws -> VCCryptoSecret {
        MockKeyManagementOperations.generateKeyCallCount += 1
        return try self.keyManagementOperations.generateKey()
    }
    
    func retrieveKeyFromStorage(withId id: UUID) -> VCCryptoSecret {
        return KeyId(id: id)
    }

    public func save(key: Data, withId id: UUID) throws {

        // Take a copy of the key to let the store dispose of it
        var data = Data()
        data.append(key)

        // Store down
        try secretStore.saveSecret(id: id,
                                   itemTypeCode: Self.itemTypeCode,
                                   accessGroup: Self.accessGroupIdentifier,
                                   value: &data)
    }

    public func deleteKey(withId id: UUID) throws {

        let itemTypeCode = Self.itemTypeCode
        let accessGroup = Self.accessGroupIdentifier
        do {
            let _ = try secretStore.getSecret(id: id,
                                              itemTypeCode: itemTypeCode,
                                              accessGroup: accessGroup)
            
            // If we get here the key exists, so we can delete it
            try secretStore.deleteSecret(id: id, itemTypeCode: itemTypeCode, accessGroup: accessGroup)
        }
        catch SecretStoringError.itemNotFound {
            /* There's no key so nothing to delete */
        }
    }

    public func getKey(withId id: UUID) throws -> Data {

        return try secretStore.getSecret(id: id,
                                         itemTypeCode: Self.itemTypeCode,
                                         accessGroup: Self.accessGroupIdentifier)

    }
}
