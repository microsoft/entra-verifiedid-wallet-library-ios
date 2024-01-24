/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Manages all of the operations for Identifiers including fetching and storing.
protocol IdentifierManager
{
    /// Fetch the main Identifier or create it if does not exist.
    func fetchOrCreateMasterIdentifier() throws -> Identifier
}
