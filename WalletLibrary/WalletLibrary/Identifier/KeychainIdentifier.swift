/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// A holder identifier that stores the private key in keychain handled by the VCCryptoSecret.
class KeychainIdentifier: HolderIdentifier
{
    /// The unique identifier (ex. did:web:microsoft.com).
    let id: String

    /// The algorithm used for cryptographic operations, such as signing.
    let algorithm: String

    /// The specific method for this identifier (ex. `did:jwk`).
    let method: String

    /// A reference to the cryptographic key used in the signing process.
    let keyReference: String

    /// A private instance of `CryptoOperations` responsible for handling cryptographic functions.
    private let cryptoOperations: CryptoOperations

    /// A private reference to the cryptographic key secret, conforming to `VCCryptoSecret`, used in signing operations.
    private let keyReferenceSecret: any VCCryptoSecret

    /// Initializes a new `KeychainIdentifier` with the specified parameters.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the entity.
    ///   - algorithm: The cryptographic algorithm to be used for signing.
    ///   - method: The verification method associated with this identifier.
    ///   - keyReference: A reference to the cryptographic key stored in the keychain.
    ///   - keyReferenceSecret: A secret reference to the cryptographic key, conforming to `VCCryptoSecret`.
    ///   - cryptoOperations: The instance of `CryptoOperations` to handle cryptographic functions.
    init(id: String,
         algorithm: String,
         method: String,
         keyReference: String,
         keyReferenceSecret: any VCCryptoSecret,
         cryptoOperations: CryptoOperations)
    {
        self.id = id
        self.algorithm = algorithm
        self.method = method
        self.keyReference = keyReference
        self.keyReferenceSecret = keyReferenceSecret
        self.cryptoOperations = cryptoOperations
    }

    /// Signs the given message using the specified algorithm and key reference secret.
    ///
    /// - Parameter message: The data to be signed.
    /// - Returns: The signed data.
    /// - Throws: An error if the signing operation fails.
    func sign(message: Data) throws -> Data
    {
        try cryptoOperations.sign(message: message,
                                  usingSecret: keyReferenceSecret,
                                  algorithm: algorithm)
    }
}
