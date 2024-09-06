/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Describes the metadata for an Identifier object.
public protocol IdentifierMetadata
{
    /// The identifying string for this object. (for example: did:web:microsoft.com)
    var id: String { get }
}
