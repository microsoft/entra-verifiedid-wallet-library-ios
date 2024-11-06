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
    
    /// Not Implemented.
    func sign(message: Data, withSecret secret: VCCryptoSecret) throws -> Data {
        
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
    
    /// Validates the signature for a given message using the given public key.
    func isValidSignature(signature: Data,
                          forMessage message: Data,
                          usingPublicKey publicKey: PublicKey) throws -> Bool {

        let pubKey = try CryptoKit.P256.Signing.PublicKey(rawRepresentation: publicKey.uncompressedValue)
        let ecdaSignature = try CryptoKit.P256.Signing.ECDSASignature(rawRepresentation: signature)
        return pubKey.isValidSignature(ecdaSignature, for: message)
    }
    
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
