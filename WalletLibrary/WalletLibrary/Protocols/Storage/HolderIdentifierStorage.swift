/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * A protocol that defines a storage interface for managing `HolderIdentifier` properties.
 */
protocol HolderIdentifierStorage
{
    /// Fetches all stored `HolderIdentifierStoredProperties` from storage.
    /// - Throws: An error if there is an issue retrieving the stored identifiers.
    /// - Returns: An array of `HolderIdentifierStoredProperties`, representing the properties of each stored identifier.
    func fetchStoredHolderIdentifiers() throws -> [HolderIdentifierStoredProperties]
    
    /// Stores a `HolderIdentifierStoredProperties` object.
    /// - Parameters:
    ///   - holder: The `HolderIdentifier` object to be stored.
    ///   - keyId: A `UUID` that uniquely identifies the holder in persistent storage.
    /// - Throws: A `CoreDataManagerError.persistentStoreNotLoaded` error if the persistent store is not loaded, or other errors related to saving the context.
    func storeHolderIdentifier(holderIdentifier: HolderIdentifierStoredProperties) throws
}
