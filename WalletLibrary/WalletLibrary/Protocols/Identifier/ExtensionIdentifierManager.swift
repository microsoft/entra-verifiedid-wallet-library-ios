/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Public protocol that handles Identifier operations used within Wallet Library Extensions.
 */
public protocol ExtensionIdentifierManager
{
    /// Given claims and types, append the claims and types to defaults, and create a self-signed Verified ID (Verifiable Credential).
    func createEphemeralSelfSignedVerifiedId(claims: [String: String], types: [String]) throws -> VerifiedId
}

