/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A protocol that defines a builder for creating `HolderIdentifier` instances with specific configurations.
 */
protocol HolderIdentifierBuilder
{
    /// Builds a `HolderIdentifier` based on the provided parameters.
    /// - Parameters:
    ///   - didMethod: The DID method to be used for constructing the identifier (e.g., "did:jwk").
    ///   - id: The Id of the identifier (e.g. "did:jwk:123"). If not present, constructed in builder.
    ///   - keyId: An optional UUID representing a unique identifier for the key, if available.
    ///   - keyReference: A string reference used to identify the key.
    ///   - algorithm: The cryptographic algorithm to be used (e.g., "ES256").
    /// - Throws: An error if the identifier could not be built with the given parameters.
    /// - Returns: A `HolderIdentifier` instance constructed according to the specified parameters.
    func buildHolderIdentifier(didMethod: String,
                               id: String?,
                               keyId: UUID?,
                               keyReference: String,
                               algorithm: String) throws -> HolderIdentifier
}
