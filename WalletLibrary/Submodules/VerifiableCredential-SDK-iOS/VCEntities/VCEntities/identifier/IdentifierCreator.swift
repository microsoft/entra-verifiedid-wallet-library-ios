/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCCrypto)
    import VCCrypto
#endif
#if canImport(VCToken)
    import VCToken
#endif

enum IdentifierCreaterError: Error {
    case unableToCasePublicKeyToECPublicKey
}

public struct IdentifierCreator {
    
    let keyManagementOperations: KeyManagementOperating
    let cryptoOperations: CryptoOperating
    let identifierFormatter: IdentifierFormatting
    let aliasComputer = AliasComputer()
    
    public init() {
        self.init(keyManagementOperations: KeyManagementOperations(sdkConfiguration: VCSDKConfiguration.sharedInstance))
    }
    
    public init(keyManagementOperations: KeyManagementOperating) {
        self.init(keyManagementOperations: keyManagementOperations, identifierFormatter: IdentifierFormatter())
    }
    
    init(keyManagementOperations: KeyManagementOperating, identifierFormatter: IdentifierFormatting) {
        self.keyManagementOperations = keyManagementOperations
        self.cryptoOperations = CryptoOperations()
        self.identifierFormatter = identifierFormatter
    }
    
    public func create(forId id: String, andRelyingParty rp: String) throws -> Identifier {
        
        let alias = aliasComputer.compute(forId: id, andRelyingParty: rp)
        
        let signingKeyContainer = KeyContainer(keyReference: try self.keyManagementOperations.generateKey(), keyId: VCEntitiesConstants.SIGNING_KEYID_PREFIX + alias)
        let updateKeyContainer = KeyContainer(keyReference: try self.keyManagementOperations.generateKey(), keyId: VCEntitiesConstants.UPDATE_KEYID_PREFIX + alias)
        let recoveryKeyContainer = KeyContainer(keyReference: try self.keyManagementOperations.generateKey(), keyId: VCEntitiesConstants.RECOVER_KEYID_PREFIX + alias)
        
        let longformDid = try self.createLongformDid(signingKeyContainer: signingKeyContainer, updateKeyContainer: updateKeyContainer, recoveryKeyContainer: recoveryKeyContainer)
        return Identifier(longFormDid: longformDid,
                          didDocumentKeys: [signingKeyContainer],
                          updateKey: updateKeyContainer,
                          recoveryKey: recoveryKeyContainer,
                          alias: alias)
        
    }
    
    private func createLongformDid(signingKeyContainer: KeyContainer, updateKeyContainer: KeyContainer, recoveryKeyContainer: KeyContainer) throws -> String {
        let signingJwk = try self.generatePublicJwk(for: signingKeyContainer)
        let updateJwk = try self.generatePublicJwk(for: updateKeyContainer)
        let recoveryJwk = try self.generatePublicJwk(for: recoveryKeyContainer)
        return try self.identifierFormatter.createIonLongFormDid(recoveryKey: recoveryJwk, updateKey: updateJwk, didDocumentKeys: [signingJwk], serviceEndpoints: [])
    }
    
    private func generatePublicJwk(for keyMapping: KeyContainer) throws -> ECPublicJwk {
        guard let publicKey = try cryptoOperations.getPublicKey(fromSecret: keyMapping.keyReference,
                                                                algorithm: SupportedCurve.Secp256k1.rawValue) as? Secp256k1PublicKey else {
            throw IdentifierCreaterError.unableToCasePublicKeyToECPublicKey
        }
        return ECPublicJwk(withPublicKey: publicKey, withKeyId: keyMapping.keyId)
    }
}
