/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Defines the behavior of resolving an Identifier Document.
 */
protocol IdentifierDocumentResolving
{
    func resolve(identifier: String) async throws -> IdentifierDocument
}
