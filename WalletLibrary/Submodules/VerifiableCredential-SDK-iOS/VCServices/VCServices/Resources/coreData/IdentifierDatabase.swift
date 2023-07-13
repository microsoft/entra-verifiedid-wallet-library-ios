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

enum IdentifierDatabaseError: Error {
    case noIdentifiersSaved
    case unableToFetchMasterIdentifier
    case unableToSaveIdentifier
    case noAliasSavedInIdentifierModel
    case noIdentifierModelSaved
    case coreDataManagerNil
}

///Temporary until Deterministic Keys are implemented
struct IdentifierDatabase {
    
    private let coreDataManager = CoreDataManager.sharedInstance
    private let aliasComputer = AliasComputer()
    private let keyManagementOperations: KeyManagementOperating
    
    init() {
        self.keyManagementOperations = KeyManagementOperations(sdkConfiguration: VCSDKConfiguration.sharedInstance)
    }
    
    init(keyManagementOperations: KeyManagementOperating) {
        self.keyManagementOperations = keyManagementOperations
    }
    
    func saveIdentifier(identifier: Identifier) throws {

        /// signing key is always first key in DID document keys until we implement more complex registration scenario.
        guard let signingKey = identifier.didDocumentKeys.first else {
            throw IdentifierDatabaseError.unableToSaveIdentifier
        }
        
        try coreDataManager.saveIdentifier(longformDid: identifier.longFormDid,
                                           signingKeyId: signingKey.getId(),
                                           recoveryKeyId: identifier.recoveryKey.getId(),
                                           updateKeyId: identifier.updateKey.getId(),
                                           alias: identifier.alias,
                                           signingKeyAlias: signingKey.keyId,
                                           recoveryKeyAlias: identifier.recoveryKey.keyId,
                                           updateKeyAlias: identifier.updateKey.keyId)
    }
    
    func fetchMasterIdentifier() throws -> Identifier {
        let alias = aliasComputer.compute(forId: VCEntitiesConstants.MASTER_ID, andRelyingParty: VCEntitiesConstants.MASTER_ID)
        return try fetchIdentifier(withAlias: alias)
    }
    
    func fetchIdentifier(withAlias alias: String) throws -> Identifier {
        
        let identifierModels = try coreDataManager.fetchIdentifiers()
        
        var identifierModel: IdentifierModel? = nil
        
        for identifier in identifierModels {
            if identifier.alias == alias {
                identifierModel = identifier
            }
        }
        
        guard let model = identifierModel else {
            throw IdentifierDatabaseError.noIdentifierModelSaved
        }
        
        return try createIdentifier(fromIdentifierModel: model)
    }
    
    func fetchIdentifier(withLongformDid did: String) throws -> Identifier {
        
        let identifierModels = try coreDataManager.fetchIdentifiers()
        
        var identifierModel: IdentifierModel? = nil
        
        for identifier in identifierModels {
            if identifier.did == did {
                identifierModel = identifier
            }
        }
        
        guard let model = identifierModel else {
            throw IdentifierDatabaseError.noIdentifierModelSaved
        }
        
        return try createIdentifier(fromIdentifierModel: model)
    }
    
    func fetchAllIdentifiers() throws -> [Identifier] {
        return try coreDataManager.fetchIdentifiers().map {
            try createIdentifier(fromIdentifierModel:$0)
        }
    }
    
    func removeAllIdentifiers() throws {
        
        try coreDataManager.fetchIdentifiers().forEach { identifierModel in
            // Step 1: remove the keys corresponding to each identifier
            let keyIds = [identifierModel.signingKeyId, identifierModel.updateKeyId, identifierModel.recoveryKeyId]
            try keyIds.forEach { keyId in
                if let uuid = keyId {
                    try keyManagementOperations.deleteKey(withId: uuid)
                }
            }
            
            // Step 2: delete the identifier
            coreDataManager.deleteIdentifer(identifierModel)
        }
    }
    
    func importIdentifier(identifier: Identifier) throws {

        // Put the keys in the keychain
        let keyContainers = identifier.didDocumentKeys + [identifier.updateKey, identifier.recoveryKey]
        try keyContainers.forEach { keyContainer in
            let secret = try EphemeralSecret(with: keyContainer.keyReference)
            try keyManagementOperations.save(key: secret.value, withId: keyContainer.keyReference.id)
        }
        
        try self.saveIdentifier(identifier: identifier)
    }
    
    private func createIdentifier(fromIdentifierModel model: IdentifierModel) throws -> Identifier {
        
        guard let longFormDid = model.did,
            let alias = model.alias else {
                throw IdentifierDatabaseError.noAliasSavedInIdentifierModel
        }
        
        let signingKeyAlias = model.signingKeyAlias ?? VCEntitiesConstants.SIGNING_KEYID_PREFIX + alias
        let signingKeyContainer = try createKeyContainer(keyRefId: model.signingKeyId, keyId: signingKeyAlias)
        let updateKeyAlias = model.updateKeyAlias ?? VCEntitiesConstants.UPDATE_KEYID_PREFIX + alias
        let updateKeyContainer = try createKeyContainer(keyRefId: model.updateKeyId, keyId: updateKeyAlias)
        let recoveryKeyAlias = model.recoveryKeyAlias ?? VCEntitiesConstants.RECOVER_KEYID_PREFIX + alias
        let recoveryKeyContainer = try createKeyContainer(keyRefId: model.recoveryKeyId, keyId: recoveryKeyAlias)
        
        return Identifier(longFormDid: longFormDid,
                          didDocumentKeys: [signingKeyContainer],
                          updateKey: updateKeyContainer,
                          recoveryKey: recoveryKeyContainer,
                          alias: alias)
    }
    
    private func createKeyContainer(keyRefId: UUID?, keyId: String) throws -> KeyContainer {
        
        guard let keyUUID = keyRefId else {
            throw IdentifierDatabaseError.unableToFetchMasterIdentifier
        }
        
        let keyRef = keyManagementOperations.retrieveKeyFromStorage(withId: keyUUID)
        return KeyContainer(keyReference: keyRef, keyId: keyId)
    }
}
