/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct KeyContainer {
    
    /// Always ES256K because we only support Secp256k1 keys
    let algorithm: String = "ES256K"
    
    /// key reference to key in Secret Store
    let keyReference: VCCryptoSecret

    /// keyId to specify key in Identifier Document (must be less than 20 chars long)
    let keyId: String
    
    init(keyReference: VCCryptoSecret,
                keyId: String) {
        self.keyReference = keyReference
        self.keyId = keyId
    }
    
    func getId() -> UUID {
        return keyReference.id
    }
    
    func isValidKey() throws {
        try keyReference.isValidKey()
    }
    
    /// Migrate key from old access group to new one set in sdk config.
    func migrateKey(fromAccessGroup currentAccessGroup: String?) throws {
        try keyReference.migrateKey(fromAccessGroup: currentAccessGroup)
    }
}
