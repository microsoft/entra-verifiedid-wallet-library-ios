/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A class responsible for managing and retrieving `HolderIdentifier` instances.
 * This class implements the `HolderIdentifierRepository` protocol and serves as a repository for storing and fetching holder identifiers.
 */
class IdentifierRepository: HolderIdentifierRepository
{
    /// An object responsible for logging
    private let logger: WalletLibraryLogger
    
    /// An object responsible for creating new holder identifiers.
    private let builder: HolderIdentifierBuilder
    
    /// An object responsible for storing and retrieving holder identifiers.
    private let storage: HolderIdentifierStorage
    
    init(logger: WalletLibraryLogger,
        builder: HolderIdentifierBuilder? = nil,
         storage: HolderIdentifierStorage = CoreDataManager.sharedInstance)
    {
        self.logger = logger
        self.builder = builder ?? KeychainHolderIdentifierBuilder(logger: logger)
        self.storage = storage
    }
    
    /// Retrieves the main holder identifier from storage or creates a new one if none exists.
    /// - Throws: An error if fetching from storage or creating a new identifier fails.
    /// - Returns: The main `HolderIdentifier` instance.
    func getMainHolderIdentifier() throws -> HolderIdentifier
    {
        logger.logVerbose(message: "Fetching HolderIdentifiers")
        let storedHolderIdentifier = try storage.fetchStoredHolderIdentifiers()
        
        logger.logVerbose(message: "Found \(storedHolderIdentifier.count) HolderIdentifiers")
        
        /// We only support one `HolderIdentifier` per user as of now.
        if let firstHolderIdentifier = storedHolderIdentifier.first
        {
            do {
                logger.logVerbose(message: "An existing HolderIdentifier was found")
                return try mapToHolderIdentifier(storedIdentifier: firstHolderIdentifier)
            } catch (let error as SecretStoringError) {
                logger.logWarning(message: "Stored HolderIdentifier has crypto key material error: \(String(describing: error))")
            }
        }
        
        // If there are no identifiers in storage, create default one using FIPS compliant keys
        // and "did:jwk" method. The key reference is always "0" for "did:jwk" dids.
        logger.logVerbose(message: "Creating a new HolderIdentifier")
        let mainIdentifier = try builder.buildHolderIdentifier(didMethod: "did:jwk",
                                                               id: nil,
                                                               keyId: nil,
                                                               keyReference: "0",
                                                               algorithm: "ES256")
        try storeNewIdentifier(identifier: mainIdentifier)
        logger.logInfo(message: "New HolderIdentifier created")
        
        return mainIdentifier
    }
    
    private func mapToHolderIdentifier(storedIdentifier: HolderIdentifierStoredProperties) throws -> HolderIdentifier
    {
        let method = try String.getRequiredProperty(property: storedIdentifier.didMethod,
                                                    propertyName: "didMethod")
        let algorithm = try String.getRequiredProperty(property: storedIdentifier.algorithm,
                                                       propertyName: "algorithm")
        let keyId = try UUID.getRequiredProperty(property: storedIdentifier.keyId,
                                                 propertyName: "KeyId")
        let keyReference = try String.getRequiredProperty(property: storedIdentifier.keyReference,
                                                          propertyName: "keyReference")
        logger.logVerbose(message: "All HolderIdentifier properties found")
        
        return try builder.buildHolderIdentifier(didMethod: method,
                                                 id: storedIdentifier.id,
                                                 keyId: keyId,
                                                 keyReference: keyReference,
                                                 algorithm: algorithm)
    }
    
    private func storeNewIdentifier(identifier: HolderIdentifier) throws
    {
        guard let mappableIdentifier = identifier as? any Mappable,
              let storedProperties = try? Mapper().map(mappableIdentifier) as? HolderIdentifierStoredProperties else
        {
            logger.logError(message: "Cannot store Identifier. Not supported type.")
            throw IdentifierError(message: "Identifier type not supported: \(type(of: identifier)).",
                                  code: "identifier_type_not_supported")
        }
        
        try storage.storeHolderIdentifier(holderIdentifier: storedProperties)
        logger.logVerbose(message: "Successfully stored HolderIdentifier")
    }
}

