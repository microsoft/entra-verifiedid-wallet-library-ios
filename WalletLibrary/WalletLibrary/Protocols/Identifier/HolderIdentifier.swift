/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// An object that describes the holder of Verified IDs.
protocol HolderIdentifier
{
    /// The unique identifier (ex. did:web:microsoft.com).
    var id: String { get }

    /// The algorithm used for cryptographic operations, such as signing (ex. ES256 defined in  https://datatracker.ietf.org/doc/html/rfc7518#section-3.1 ).
    var algorithm: String { get }

    /// The specific method for this identifier (ex. `did:jwk`).
    var method: String { get }

    /// A reference to the cryptographic key used in the signing process.
    var keyReference: String { get }

    /// Signs the given message using the specified algorithm and key.
    /// - Parameter message: The data to be signed.
    /// - Returns: The signed data.
    /// - Throws: An error if the signing process fails.
    func sign(message: Data) throws -> Data
}
