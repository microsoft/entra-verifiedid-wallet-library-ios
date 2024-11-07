/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A class responsible for building `HolderIdentifier` instances using key management and cryptographic operations.
 * This class implements the `HolderIdentifierBuilder` protocol.
 */
class KeychainHolderIdentifierBuilder: HolderIdentifierBuilder
{
    /// An object responsible for performing key management operations, such as key creation, retrieval, or deletion.
    private let keyManagementOperations: KeyManagementOperating
    
    /// An object responsible for performing cryptographic operations, such as signing or encrypting data.
    private let cryptoOperations: CryptoOperating
    
    /// An instance of `DIDBuilder` used for creating decentralized identifiers (DIDs).
    private let didBuilder: DIDBuilder
    
    init(keyManagementOperations: KeyManagementOperating, cryptoOperations: CryptoOperating) 
    {
        self.keyManagementOperations = keyManagementOperations
        self.cryptoOperations = cryptoOperations
        self.didBuilder = DIDBuilder()
    }
    
    /// Builds a `HolderIdentifier` based on the provided parameters. If keyId is nil, generate a new key.
    /// - Parameters:
    ///   - didMethod: The method used for constructing the DID (e.g., "did:jwk").
    ///   - keyId: An optional UUID representing a unique identifier for the key.
    ///   - keyReference: A string reference for identifying the key.
    ///   - algorithm: The algorithm used for cryptographic operations (e.g., "ES256").
    /// - Throws: An error if the building process fails.
    /// - Returns: A `HolderIdentifier` constructed with the specified parameters.
    func buildHolderIdentifier(didMethod: String,
                               keyId: UUID? = nil,
                               keyReference: String,
                               algorithm: String) throws -> HolderIdentifier
    {
        // We only support DID:JWK method for now.
        guard didMethod == "did:jwk" else
        {
            throw IdentifierError(message: "Unsupported DID Method: \(didMethod).",
                                  code: "unsupported_did_method")
        }
        
        let key = try retrieveOrGenerateNewKey(keyId: keyId)
        
        let publicKey = try cryptoOperations.getPublicKey(fromSecret: key, algorithm: algorithm)
        
        let did = try didBuilder.build(from: publicKey, method: didMethod)
        
        let identifier = KeychainIdentifier(id: did,
                                            algorithm: algorithm,
                                            method: didMethod,
                                            keyReference: keyReference,
                                            keyReferenceSecret: key,
                                            cryptoOperations: cryptoOperations)
        
        return identifier
    }
    
    private func retrieveOrGenerateNewKey(keyId: UUID?) throws -> VCCryptoSecret
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
