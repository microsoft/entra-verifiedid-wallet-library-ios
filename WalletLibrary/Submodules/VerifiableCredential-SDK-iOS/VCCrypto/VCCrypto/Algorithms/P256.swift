/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import CryptoKit

enum P256Error: Error, Equatable
{
    case InvalidKeyMaterialInJWK
    case JWKContainsInvalidKeyType(String)
    case JWKContainsInvalidCurveAlgorithm(String?)
    case MissingKeyMaterialInJWK
    case NotImplemented
}

/// Algorithm that verifies a message using the P256 algorithm.
struct P256: Signing {
    
    private struct Constants {
        static let KeyType = "EC"
        static let Algorithm = "P-256"
    }
    
    /// Not Implemented.
    func sign(message: Data, withSecret secret: VCCryptoSecret) throws -> Data {
        throw P256Error.NotImplemented
    }
    
    /// Validates the signature for a given message using the given public key.
    func isValidSignature(signature: Data,
                          forMessage message: Data,
                          usingPublicKey publicKey: PublicKey) throws -> Bool {

        let pubKey = try CryptoKit.P256.Signing.PublicKey(rawRepresentation: publicKey.uncompressedValue)
        let ecdaSignature = try CryptoKit.P256.Signing.ECDSASignature(rawRepresentation: signature)
        return pubKey.isValidSignature(ecdaSignature, for: message)
    }
    
    /// Not Implemented.
    func createPublicKey(forSecret secret: VCCryptoSecret) throws -> PublicKey {
        throw P256Error.NotImplemented
    }
    
    /// Creates a public key from JWK format.
    func createPublicKey(fromJWK key: JWK) throws -> PublicKey {
        
        guard key.keyType == Constants.KeyType else {
            throw P256Error.JWKContainsInvalidKeyType(key.keyType)
        }
        
        guard key.curve == Constants.Algorithm else {
            throw P256Error.JWKContainsInvalidCurveAlgorithm(key.curve)
        }

        guard let x = key.x, let y = key.y else {
            throw P256Error.MissingKeyMaterialInJWK
        }
        
        guard let publicKey = P256PublicKey(x: x, y: y) else {
            throw P256Error.InvalidKeyMaterialInJWK
        }
        
        return publicKey
    }
}
