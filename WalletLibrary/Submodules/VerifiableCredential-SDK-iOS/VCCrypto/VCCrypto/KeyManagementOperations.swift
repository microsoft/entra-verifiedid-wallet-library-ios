/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Operations that are involved in key management.
public struct KeyManagementOperations: KeyManagementOperating {

    private let secretStore: SecretStoring
    
    private let sdkConfiguration: VCSDKConfigurable
    
    public init(sdkConfiguration: VCSDKConfigurable) {
        self.init(secretStore: KeychainSecretStore(), sdkConfiguration: sdkConfiguration)
    }
    
    public init(secretStore: SecretStoring, sdkConfiguration: VCSDKConfigurable) {
        self.secretStore = secretStore
        self.sdkConfiguration = sdkConfiguration
    }
    
    public func generateKey() throws -> VCCryptoSecret {
        let accessGroup = sdkConfiguration.accessGroupIdentifier
        let key = try Random32BytesSecret(withStore: secretStore, inAccessGroup: accessGroup)
        return key
    }
    
    public func retrieveKeyFromStorage(withId id: UUID) -> VCCryptoSecret {
        let accessGroup = sdkConfiguration.accessGroupIdentifier
        return Random32BytesSecret(withStore: secretStore, andId: id, inAccessGroup: accessGroup)
    }
    
    public func save(key: Data, withId id: UUID) throws {

        // Take a copy of the key to let the store dispose of it
        var data = Data()
        data.append(key)

        // Format the item type code
        let itemTypeCode = String(format: "r%02dB", data.count)

        // Store down
        try secretStore.saveSecret(id: id,
                                   itemTypeCode: itemTypeCode,
                                   accessGroup: sdkConfiguration.accessGroupIdentifier,
                                   value: &data)
    }

    public func deleteKey(withId id: UUID) throws {

        let itemTypeCode = Random32BytesSecret.itemTypeCode
        let accessGroup = sdkConfiguration.accessGroupIdentifier
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
                                         itemTypeCode: Random32BytesSecret.itemTypeCode,
                                         accessGroup: sdkConfiguration.accessGroupIdentifier)

    }
}
