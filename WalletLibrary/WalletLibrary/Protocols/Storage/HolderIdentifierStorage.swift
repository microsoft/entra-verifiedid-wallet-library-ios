/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

protocol HolderIdentifierStorage
{
    func fetchStoredHolderIdentifiers() throws -> [HolderIdentifierStoredProperties]
    
    /// Stores a `HolderIdentifier` object in the persistent storage.
    /// - Parameters:
    ///   - holder: The `HolderIdentifier` object to be stored.
    ///   - keyId: A `UUID` that uniquely identifies the holder in persistent storage.
    /// - Throws: A `CoreDataManagerError.persistentStoreNotLoaded` error if the persistent store is not loaded, or other errors related to saving the context.
    func storeHolderIdentifier(holderIdentifier: HolderIdentifierStoredProperties) throws
}
