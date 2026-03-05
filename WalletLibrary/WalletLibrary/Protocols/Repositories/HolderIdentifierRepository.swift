/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A protocol that defines a repository responsible for managing and retrieving `HolderIdentifier` instances.
 * We only support one stored Identifier as of now.
 */
protocol HolderIdentifierRepository
{
    /// Retrieves the main `HolderIdentifier` from the repository.
    /// - Throws: An error if there is an issue retrieving the `HolderIdentifier`.
    /// - Returns: The main `HolderIdentifier` instance.
    func getMainHolderIdentifier() throws -> HolderIdentifier
    
    /// Prunes the repository of `HolderIdentifier`s not found in the keychain.
    /// - Throws: unexpected keychain/storage errors
    func pruneHolderIdentifiers() throws
}
