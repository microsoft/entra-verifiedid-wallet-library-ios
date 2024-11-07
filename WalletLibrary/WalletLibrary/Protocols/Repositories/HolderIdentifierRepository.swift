/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A protocol that defines a repository responsible for managing and retrieving `HolderIdentifier` instances.
 */
protocol HolderIdentifierRepository
{
    /// Retrieves the main `HolderIdentifier` from the repository.
    /// - Throws: An error if there is an issue retrieving the `HolderIdentifier`.
    /// - Returns: The main `HolderIdentifier` instance.
    func getMainHolderIdentifier() throws -> HolderIdentifier
}
