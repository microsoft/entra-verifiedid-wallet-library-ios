/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// A protocol for objects that can be represented by a JWK (JSON Web Key).
/// Types conforming to this protocol provide a way to expose their public key representation.
public protocol JWKRepresentable
{
    /// Represents the public key in `PublicJWK` format.
    ///
    /// - Returns: An `PublicJWK` object representing the public key.
    /// - Throws: An error if the public key cannot be exported (e.g., due to missing or malformed data).
    func getPublicKey() throws -> PublicJWK
}

