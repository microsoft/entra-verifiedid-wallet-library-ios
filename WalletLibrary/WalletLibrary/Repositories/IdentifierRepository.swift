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
    /// An object responsible for creating new holder identifiers.
    private let builder: HolderIdentifierBuilder
    
    /// An object responsible for storing and retrieving holder identifiers.
    private let storage: HolderIdentifierStorage
    
    init(builder: HolderIdentifierBuilder,
         storage: HolderIdentifierStorage)
    {
        self.builder = builder
        self.storage = storage
    }
    
    /// Retrieves the main holder identifier from storage or creates a new one if none exists.
    /// - Throws: An error if fetching from storage or creating a new identifier fails.
    /// - Returns: The main `HolderIdentifier` instance.
    func getMainHolderIdentifier() throws -> HolderIdentifier
    {
        let storedHolderIdentifier = try storage.fetchStoredHolderIdentifiers()
        
        /// We only support one `HolderIdentifier` per user as of now.
        if let firstHolderIdentifier = storedHolderIdentifier.first
        {
            return try mapToHolderIdentifier(storedIdentifier: firstHolderIdentifier)
        }
        else
        {
            // If there are no identifiers in storage, create default one using FIPS compliant keys
            // and "did:jwk" method.
            let mainIdentifier = try builder.buildHolderIdentifier(didMethod: "did:jwk",
                                                                   keyId: nil,
                                                                   keyReference: "main",
                                                                   algorithm: "ES256")
            try storeNewIdentifier(identifier: mainIdentifier)
            
            return mainIdentifier
        }
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
        
        return try builder.buildHolderIdentifier(didMethod: method,
                                                 keyId: keyId,
                                                 keyReference: keyReference,
                                                 algorithm: algorithm)
    }
    
    private func storeNewIdentifier(identifier: HolderIdentifier) throws
    {
        guard let mappableIdentifier = identifier as? any Mappable,
              let storedProperties = try? Mapper().map(mappableIdentifier) as? HolderIdentifierStoredProperties else
        {
            throw IdentifierError(message: "Identifier type not supported: \(type(of: identifier)).",
                                  code: "identifier_type_not_supported")
        }
        
        try storage.storeHolderIdentifier(holderIdentifier: storedProperties)
    }
}

