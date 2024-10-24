/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum Secp256k1SignerError: Error {
    case unableToCastPublicKeyToSecp256K1PublicKey
}

/// TODO: refactor class to be a generic signer.
struct Secp256k1Signer: TokenSigning {
    
    private let cryptoOperations: CryptoOperating
    
    init(cryptoOperations: CryptoOperating = CryptoOperations()) {
        self.cryptoOperations = cryptoOperations
    }

    func sign<T>(token: JwsToken<T>, withSecret secret: VCCryptoSecret) throws -> Signature {
        
        let encodedMessage = token.protectedMessage

        guard let messageData = encodedMessage.data(using: .ascii) else {
            throw TokenError.UnableToParseToken(component: "message")
        }
        
        return try cryptoOperations.sign(message: messageData,
                                         usingSecret: secret,
                                         algorithm: SupportedCurve.Secp256k1.rawValue)
    }
    
    func getPublicJwk(from secret: VCCryptoSecret, withKeyId keyId: String) throws -> ECPublicJwk {
        
        let publicKey = try cryptoOperations.getPublicKey(fromSecret: secret,
                                                          algorithm: SupportedCurve.Secp256k1.rawValue)
        
        guard let key = publicKey as? Secp256k1PublicKey else {
            throw Secp256k1SignerError.unableToCastPublicKeyToSecp256K1PublicKey
        }
        
        return ECPublicJwk(withPublicKey: key, withKeyId: keyId)
    }
}
