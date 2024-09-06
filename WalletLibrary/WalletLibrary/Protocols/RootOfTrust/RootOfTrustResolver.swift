/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Defines the behavior of resolving the Root of Trust.
 * An implementation of this protocol can be injected into the VerifiedIdClient.
 */
public protocol RootOfTrustResolver 
{
    /// Resolve the `RootOfTrust` from the given `IdentifierMetadata` to determine whether the
    /// identifier can be trusted. (for example: Linked Domain)
    func resolve(from identifier: IdentifierMetadata) async throws -> RootOfTrust
}
