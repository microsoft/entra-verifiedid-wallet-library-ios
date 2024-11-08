/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// A protocol for objects that can be represented by a JWK (JSON Web Key).
/// Types conforming to this protocol provide a way to expose their public key representation.
public protocol JWKRepresentable
{
    /// Exports the public key in `ECPublicJwk` format.
    ///
    /// - Returns: An `ECPublicJwk` object representing the public key.
    /// - Throws: An error if the public key cannot be exported (e.g., due to missing or malformed data).
    func getPublicKey() throws -> PublicJWK
}

