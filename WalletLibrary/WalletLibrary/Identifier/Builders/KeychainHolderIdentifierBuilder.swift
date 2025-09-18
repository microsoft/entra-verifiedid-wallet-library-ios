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
    /// An object responsible for logging
    private let logger: WalletLibraryLogger
    
    /// An object responsible for performing key management operations, such as key creation, retrieval, or deletion.
    private let keyManagementOperations: KeyManagementOperating
    
    /// An object responsible for performing cryptographic operations, such as signing or encrypting data.
    private let cryptoOperations: CryptoOperating
    
    /// An instance of `DIDBuilder` used for creating decentralized identifiers (DIDs).
    private let didBuilder: DIDBuilder
    
    init(logger: WalletLibraryLogger,
         keyManagementOperations: KeyManagementOperating = KeyManagementOperations(),
         cryptoOperations: CryptoOperating = CryptoOperations())
    {
        self.logger = logger
        self.keyManagementOperations = keyManagementOperations
        self.cryptoOperations = cryptoOperations
        self.didBuilder = DIDBuilder()
    }
    
    /// Builds a `HolderIdentifier` based on the provided parameters. If keyId is nil, generate a new key.
    /// - Parameters:
    ///   - didMethod: The method used for constructing the DID (e.g., "did:jwk").
    ///   - id: The Id of the identifier (e.g. "did:jwk:123"). If not present, constructed in builder.
    ///   - keyId: An optional UUID representing a unique identifier for the key.
    ///   - keyReference: A string reference for identifying the key.
    ///   - algorithm: The algorithm used for cryptographic operations (e.g., "ES256").
    /// - Throws: An error if the building process fails.
    /// - Returns: A `HolderIdentifier` constructed with the specified parameters.
    func buildHolderIdentifier(didMethod: String,
                               id: String? = nil,
                               keyId: UUID? = nil,
                               keyReference: String,
                               algorithm: String) throws -> HolderIdentifier
    {
        logger.logDebug(message: "Building Identifier")
        // We only support DID:JWK method for now.
        guard didMethod == "did:jwk" else
        {
            logger.logError(message: "Unsupported DID Method: \(didMethod)")
            throw IdentifierError(message: "Unsupported DID Method: \(didMethod).",
                                  code: "unsupported_did_method")
        }
        
        let key = try retrieveOrGenerateNewKey(keyId: keyId)
        logger.logDebug(message: "Got private key")
        
        let publicKey = try cryptoOperations.getPublicKey(fromSecret: key, algorithm: algorithm)
        logger.logDebug(message: "Generated public key")
        
        let did = try buildDIDIfNeeded(id: id,
                                       didMethod: didMethod,
                                       publicKey: publicKey)
        
        let identifier = KeychainIdentifier(id: did,
                                            algorithm: algorithm,
                                            method: didMethod,
                                            keyReference: keyReference,
                                            keyReferenceSecret: key,
                                            cryptoOperations: cryptoOperations)
        
        logger.logInfo(message: "Successfully built identifier")
        return identifier
    }
    
    private func buildDIDIfNeeded(id: String?, 
                                  didMethod: String,
                                  publicKey: PublicKey) throws -> String
    {
        if let id = id
        {
            return id
        }
        
        logger.logDebug(message: "Building decentralized identifier")
        return try didBuilder.build(from: publicKey, method: didMethod)
    }
    
    private func retrieveOrGenerateNewKey(keyId: UUID?) throws -> VCCryptoSecret
    {
        if let keyId = keyId
        {
            logger.logDebug(message: "Retrieving private key")
            return keyManagementOperations.retrieveKeyFromStorage(withId: keyId)
        }
        else
        {
            logger.logDebug(message: "Generating new private key")
            return try keyManagementOperations.generateKey()
        }
    }
}
