/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Defines the metadata for an public Identifier object that defines an issuer/verifier.
 * This metadata might be an Identifier Document and can be used to determine the root of trust.
 */
public protocol IdentifierMetadata
{
    /// The identifying string for this object. (for example: did:web:microsoft.com)
    var id: String { get }
}
