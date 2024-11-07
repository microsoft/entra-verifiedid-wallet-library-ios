/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct HolderIdentifierCreator
{
    private let keyManagementOperations: KeyManagementOperating
    
    private let cryptoOperations: CryptoOperating
    
    private let didCreator: DIDCreator
    
    init(keyManagementOperations: KeyManagementOperating, cryptoOperations: CryptoOperating) 
    {
        self.keyManagementOperations = keyManagementOperations
        self.cryptoOperations = cryptoOperations
        self.didCreator = DIDCreator()
    }
    
    func createHolderIdentifier(didMethod: String,
                                keyId: UUID? = nil,
                                keyReference: String,
                                algorithm: String) throws -> HolderIdentifier
    {
        // We only support DID:JWK method for now.
        guard didMethod == "did:jwk" else
        {
            throw VerifiedIdError(message: "", code: "")
        }
        
        let key = try retrieveOrGenerateNewKey(keyId: keyId)
        
        let publicKey = try cryptoOperations.getPublicKey(fromSecret: key, algorithm: algorithm)
        
        let did = try didCreator.createDID(from: publicKey, method: didMethod)
        
        let identifier = KeychainIdentifier(id: did,
                                            algorithm: algorithm,
                                            method: didMethod,
                                            keyReference: keyReference,
                                            keyReferenceSecret: key,
                                            cryptoOperations: cryptoOperations)
        
        return identifier
    }
    
    func retrieveOrGenerateNewKey(keyId: UUID?) throws -> VCCryptoSecret
    {
        if let keyId = keyId
        {
            return keyManagementOperations.retrieveKeyFromStorage(withId: keyId)
        }
        else
        {
            return try keyManagementOperations.generateKey()
        }
    }
}

class HolderIdentifierProvider
{
    private let creator: HolderIdentifierCreator
    
    private let storage: CoreDataManager
    
    init(creator: HolderIdentifierCreator, storage: CoreDataManager) 
    {
        self.creator = creator
        self.storage = storage
    }
    
    func provideHolderIdentifiers() throws -> [HolderIdentifier]
    {
        let storedHolderIdentifiers = try storage.fetchStoredHolderIdentifiers()
        let holderIdentifiers = try storedHolderIdentifiers.map {
            try mapStoredIdentifierToHolderIdentifier(storedIdentifier: $0)
        }
        
        if holderIdentifiers.isEmpty
        {
            let mainIdentifier = try creator.createHolderIdentifier(didMethod: "did:jwk", keyReference: "main", algorithm: "ES256")
            return [mainIdentifier]
        }
        else
        {
            return holderIdentifiers
        }
    }
    
    func mapStoredIdentifierToHolderIdentifier(storedIdentifier: HolderIdentifierDataModel) throws -> HolderIdentifier
    {
        let method = try String.getRequiredProperty(property: storedIdentifier.didMethod, propertyName: "didMethod")
        let algorithm = try String.getRequiredProperty(property: storedIdentifier.algorithm, propertyName: "algorithm")
        let keyId = try UUID.getRequiredProperty(property: storedIdentifier.keyId, propertyName: "KeyId")
        let keyReference = try String.getRequiredProperty(property: storedIdentifier.keyReference, propertyName: "keyReference")
        
        return try creator.createHolderIdentifier(didMethod: method,
                                                  keyId: keyId,
                                                  keyReference: keyReference,
                                                  algorithm: algorithm)
    }
}

struct DIDCreator
{
    func createDID(from publicKey: PublicKey, method: String) throws -> String
    {
        // Only support ES256 keys and did:jwk method for now.
        guard let ecPublicKey = publicKey as? ES256PublicKey,
              method == "did:jwk" else
        {
            throw VerifiedIdError(message: "", code: "")
        }
        
        let jwk: [String: String] =
        [
            "crv": ecPublicKey.curve,
            "kty": ecPublicKey.keyType,
            "x": ecPublicKey.x.base64URLEncodedString(),
            "y": ecPublicKey.y.base64URLEncodedString()
        ]
        
        let serializedJWK = try JSONSerialization.data(withJSONObject: jwk)
        let base64EncodedJWK = serializedJWK.base64URLEncodedString()
        return "did:jwk:\(base64EncodedJWK)"
    }
}
