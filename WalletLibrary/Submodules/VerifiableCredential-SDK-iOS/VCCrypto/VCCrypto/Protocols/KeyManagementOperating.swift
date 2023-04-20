/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Operations that involve managing keys.
public protocol KeyManagementOperating {
    
    /// Generate a new key and return the secret.
    func generateKey() throws -> VCCryptoSecret
    
    /// Retrieve key from storage.
    func retrieveKeyFromStorage(withId id: UUID) -> VCCryptoSecret
    
    /// Save key with uner a particular id.
    func save(key: Data, withId id: UUID) throws
    
    /// Delete key from key stoage.
    func deleteKey(withId id: UUID) throws
    
    /// Get key from stroage and return raw value.
    func getKey(withId id: UUID) throws -> Data
}
