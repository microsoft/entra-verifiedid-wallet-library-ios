/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Cryptopgraphic Operations needed for verification.
public protocol CryptoOperating {
    
    /// Sign a message using a specific secret, and return the signature.
    func sign(message: Data, usingSecret secret: VCCryptoSecret, algorithm: String) throws -> Data
    
    /// Get a public key derived from the secret.
    func getPublicKey(fromSecret secret: VCCryptoSecret, algorithm: String) throws -> PublicKey
    
    /// Verify signature for the message using a public key and return true if valid signature, false if invalid.
    func verify(signature: Data, forMessage message: Data, usingPublicKey publicKey: PublicKey) throws -> Bool
}
