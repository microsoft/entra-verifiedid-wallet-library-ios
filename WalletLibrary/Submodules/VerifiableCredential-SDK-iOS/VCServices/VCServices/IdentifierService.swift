/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

#if canImport(VCCrypto)
    import VCCrypto
#endif

public enum IdentifierServiceError: Error {
    case keyNotFoundInKeyStore(innerError: Error)
    case keyStoreError(message: String)
    case noKeysSavedForIdentifier
}

public class IdentifierService {
    
    private let identifierDB: IdentifierDatabase
    private let identifierCreator: IdentifierCreator
    private let sdkLog: VCSDKLog
    private let aliasComputer = AliasComputer()
    
    public convenience init() {
        let keyManagementOperations = KeyManagementOperations(sdkConfiguration: VCSDKConfiguration.sharedInstance)
        self.init(database: IdentifierDatabase(keyManagementOperations: keyManagementOperations),
                  creator: IdentifierCreator(keyManagementOperations: keyManagementOperations),
                  sdkLog: VCSDKLog.sharedInstance)
    }
    
    init(database: IdentifierDatabase,
         creator: IdentifierCreator,
         sdkLog: VCSDKLog = VCSDKLog.sharedInstance) {
        self.identifierDB = database
        self.identifierCreator = creator
        self.sdkLog = sdkLog
    }
    
    public func fetchMasterIdentifier() throws -> Identifier {
        return try identifierDB.fetchMasterIdentifier()
    }
    
    func fetchOrCreateMasterIdentifier() throws -> Identifier {
        
        let identifier: Identifier
        do {
            identifier = try fetchMasterIdentifier()
        } catch {
            sdkLog.logError(message: "Master identifier does not exist with error: \(String(describing: error))")
            sdkLog.logInfo(message: "Creating new Identifier.")
            return try createMasterIdentifier()
        }
        
        do {
            try validateAndHandleKeys(for: identifier)
            return identifier
        } catch {
            /// in rare chance no keys are saved, create a new identifier.
            if case IdentifierServiceError.noKeysSavedForIdentifier = error {
                return try refreshIdentifiers()
            } else {
                throw error
            }
        }
    }
    
    func createMasterIdentifier() throws -> Identifier {
        try createAndSaveIdentifier(forId: VCEntitiesConstants.MASTER_ID, andRelyingParty: VCEntitiesConstants.MASTER_ID)
    }
    
    private func refreshIdentifiers() throws -> Identifier {
        try identifierDB.removeAllIdentifiers()
        let identifier = try createMasterIdentifier()
        sdkLog.logInfo(message: "Refreshed identifier.")
        return identifier
    }
    
    public func fetchIdentifiersForExport() throws -> [Identifier] {
        return try identifierDB.fetchAllIdentifiers()
    }
    
    public func replaceIdentifiers(with identifiers:[Identifier]) throws {
        
        try identifierDB.removeAllIdentifiers()
        try identifiers.forEach { identifier in
            try identifierDB.importIdentifier(identifier: identifier)
            
            // Ensure the keys are migrated into the correct access group
            let alias = identifier.alias
            do {
                let fetched = try identifierDB.fetchIdentifier(withAlias: alias)
                try migrateKeys(in: fetched, fromAccessGroup: nil)
            }
            catch {
                sdkLog.logWarning(message: "Failed to migrate keys in imported identifier w/alias: \(alias)")
            }
        }
    }
    
    func fetchIdentifier(withAlias alias: String) throws -> Identifier {
        return try identifierDB.fetchIdentifier(withAlias: alias)
    }
    
    func fetchIdentifier(forId id: String, andRelyingParty rp: String) throws -> Identifier {
        let alias = aliasComputer.compute(forId: id, andRelyingParty: rp)
        let identifier = try identifierDB.fetchIdentifier(withAlias: alias)
        sdkLog.logInfo(message: "Fetched Identifier")
        return identifier
    }
    
    func fetchIdentifer(withLongformDid did: String) throws -> Identifier? {
        return try identifierDB.fetchIdentifier(withLongformDid: did)
    }
    
    func createAndSaveIdentifier(forId id: String, andRelyingParty rp: String) throws -> Identifier {
        let identifier = try identifierCreator.create(forId: id, andRelyingParty: rp)
        try identifierDB.saveIdentifier(identifier: identifier)
        sdkLog.logVerbose(message: "Created Identifier with alias:\(identifier.alias)")
        return identifier
    }
    
    private func validateAndHandleKeys(for identifier: Identifier) throws
    {
        do {
            /// Step 1: Check to see if keys are valid.
            try areKeysValid(for: identifier)
        } catch {
            
            /// Step 2: If keys are not valid, check to see if we need to migrate keys.
            if case IdentifierServiceError.keyNotFoundInKeyStore = error {
                try migrateKeys()
                return
            }
            
            /// Else, throw error.
            throw error
        }
    }
    
    /// Migrate keys from default access group to new access group.
    private func migrateKeys() throws
    {
        do {
            /// Step 3: migrate keys.
            try migrateKeys(fromAccessGroup: nil)
            sdkLog.logInfo(message: "Keys successfully migrated to new access group.")
        } catch {
            sdkLog.logError(message: "failed to migrate keys to new access group with error: \(String(describing: error))")
            throw IdentifierServiceError.noKeysSavedForIdentifier
        }
    }
    
    /// updates access group for keys if it needs to be updated.
    private func migrateKeys(fromAccessGroup currentAccessGroup: String?) throws {
        let identifier = try fetchMasterIdentifier()
        try migrateKeys(in: identifier, fromAccessGroup: currentAccessGroup)
    }
    
    private func migrateKeys(in identifier: Identifier, fromAccessGroup currentAccessGroup: String?) throws {
        try identifier.recoveryKey.migrateKey(fromAccessGroup: currentAccessGroup)
        try identifier.updateKey.migrateKey(fromAccessGroup: currentAccessGroup)
        try identifier.didDocumentKeys.forEach { keyContainer in
            try keyContainer.migrateKey(fromAccessGroup: currentAccessGroup)
        }
    }
    
    private func areKeysValid(for identifier: Identifier) throws {
        do {
            try identifier.recoveryKey.isValidKey()
            try identifier.updateKey.isValidKey()
            
            for key in identifier.didDocumentKeys {
                try key.isValidKey()
            }
        }
        catch {
            
            if case SecretStoringError.itemNotFound = error {
                throw IdentifierServiceError.keyNotFoundInKeyStore(innerError: error)
            }
            
            if case SecretStoringError.readFromStoreError(status: _, message: let message) = error {
                throw IdentifierServiceError.keyStoreError(message: message ?? "Unable to retrieve keys")
            }
            
            /// rethrow error if not key not found error.
            throw error
        }
    }
}
