/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import CryptoKit

class ES256Error: VerifiedIdError
{
    static let InvalidSecretType = ES256Error(message: "Invalid Secret Type", code: "invalid_secret_type")
    static let InvalidSecretSize = ES256Error(message: "Invalid Secret Size", code: "invalid_secret_size")
}

/// ECDSA using P-256 and SHA-256.
struct ES256: Signing {
    
    private struct Constants {
        static let KeyType = "EC"
        static let Curve = "P-256"
    }
    
    /// Signs a given message using a cryptographic secret.
    /// - Parameters:
    ///   - message: The `Data` object representing the message that needs to be signed.
    ///   - secret: A `VCCryptoSecret` object used to perform the cryptographic signing.
    /// - Returns: A `Data` object containing the signed message.
    /// - Throws: An error if the signing operation fails.
    func sign(message: Data, withSecret secret: VCCryptoSecret) throws -> Data 
    {
        guard let secret = secret as? Secret else
        {
            throw ES256Error.InvalidSecretType
        }
        
        var rawSignature = Data()
        try secret.withUnsafeBytes { (secretPtr) in
            
            let rawKey = secretPtr.bindMemory(to: UInt8.self)
            
            guard rawKey.count == 32 else
            {
                throw ES256Error.InvalidSecretSize
            }
            
            let privateKey = try CryptoKit.P256.Signing.PrivateKey(rawRepresentation: rawKey)
            let signature = try privateKey.signature(for: message)
            rawSignature = signature.rawRepresentation
        }
        
        return rawSignature
    }
    
    /// Verifies if the given signature is valid for a specified message using a provided public key using ES256 algorithm.
    /// - Parameters:
    ///   - signature: A `Data` object representing the cryptographic signature to be validated.
    ///   - message: A `Data` object containing the original message that was signed.
    ///   - publicKey: A `PublicKey` used to verify the authenticity of the signature.
    /// - Returns: A `Bool` value indicating whether the signature is valid (`true`) or not (`false`).
    /// - Throws: An error if the verification process fails.
    func isValidSignature(signature: Data,
                          forMessage message: Data,
                          usingPublicKey publicKey: PublicKey) throws -> Bool 
    {
        let pubKey = try CryptoKit.P256.Signing.PublicKey(rawRepresentation: publicKey.uncompressedValue)
        let ecdaSignature = try CryptoKit.P256.Signing.ECDSASignature(rawRepresentation: signature)
        return pubKey.isValidSignature(ecdaSignature, for: message)
    }
    
    /// Generates a ES256 public key corresponding to the given cryptographic secret.
    /// - Parameter secret: A `VCCryptoSecret` instance used to derive the public key.
    /// - Returns: A `PublicKey` object derived from the provided secret.
    /// - Throws: An error if the public key creation fails.
    func createPublicKey(forSecret secret: VCCryptoSecret) throws -> PublicKey
    {
        guard let secret = secret as? Secret else
        {
            throw ES256Error.InvalidSecretType
        }
        
        var publicKey: ES256PublicKey? = nil
        try secret.withUnsafeBytes { (secretPtr) in
            
            let rawKey = secretPtr.bindMemory(to: UInt8.self)
            
            guard rawKey.count == 32 else
            {
                throw ES256Error.InvalidSecretSize
            }
            
            let privateKey = try CryptoKit.P256.Signing.PrivateKey(rawRepresentation: rawKey)
            let rawPublicKey = privateKey.publicKey.rawRepresentation
            
            // The first byte is 0x04 for uncompressed point format (indicating x and y follow)
            let x = rawPublicKey[1..<33] // 32 bytes for x
            let y = rawPublicKey[33..<65] // 32 bytes for y
            publicKey = ES256PublicKey(x: x, y: y)
        }
        
        guard let publicKey = publicKey else
        {
            throw ES256Error(message: "Unable to create public key.",
                             code: "Unable to create public key.")
        }
        
        
        return publicKey
    }
    
    /// Creates a public key from JWK format.
    func createPublicKey(fromJWK key: JWK) throws -> PublicKey 
    {
        guard key.keyType == Constants.KeyType else 
        {
            throw ES256Error(message: "JWK contains invalid key type: \(key.keyType).",
                             code: "invalid_keytype")
        }
        
        guard key.curve == Constants.Curve else 
        {
            throw ES256Error(message: "JWK contains invalid curve type: \(key.curve ?? "").",
                             code: "invalid_curve")
        }

        guard let x = key.x, 
              let y = key.y,
              let publicKey = ES256PublicKey(x: x, y: y) else
        {
            throw ES256Error(message: "Missing Key Material in JWK.",
                             code: "missing_key_material")
        }
        
        return publicKey
    }
}
