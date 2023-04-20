/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCCrypto)
    import VCCrypto
#endif

enum TokenVerifierError: Error, Equatable {
    case malformedProtectedMessageInToken
    case missingKeyMaterialInJWK
    case unsupportedAlgorithmFoundInJWK(algorithm: String?)
}

public struct TokenVerifier: TokenVerifying {
    
    private let cryptoOperations: CryptoOperating
    
    public init(cryptoOperations: CryptoOperating = CryptoOperations()) {
        self.cryptoOperations = cryptoOperations
    }
    
    public func verify<T>(token: JwsToken<T>, usingPublicKey key: JWK) throws -> Bool {
        
        guard let signature = token.signature else {
            return false
        }
        
        guard let encodedMessage = token.protectedMessage.data(using: .ascii) else {
            throw TokenVerifierError.malformedProtectedMessageInToken
        }
        
        return try cryptoOperations.verify(signature: signature, forMessage: encodedMessage, usingPublicKey: transformKey(key: key))
    }
    
    private func transformKey(key: JWK) throws -> PublicKey {
        switch key.curve?.uppercased() {
        case SupportedCurve.Secp256k1.rawValue:
            return try transformSecp256k1(key: key)
        case SupportedCurve.ED25519.rawValue:
            return try transformED25519(key: key)
        default:
            throw TokenVerifierError.unsupportedAlgorithmFoundInJWK(algorithm: key.curve)
        }
    }
    
    private func transformSecp256k1(key: JWK) throws -> Secp256k1PublicKey {
        guard let x = key.x, let y = key.y,
              let secpKey = Secp256k1PublicKey(x: x, y: y) else {
            throw TokenVerifierError.missingKeyMaterialInJWK
        }
        
        return secpKey
    }
    
    private func transformED25519(key: JWK) throws -> ED25519PublicKey {
        guard let x = key.x,
              let edKey = ED25519PublicKey(x: x) else {
            throw TokenVerifierError.missingKeyMaterialInJWK
        }
        
        return edKey
    }
}


