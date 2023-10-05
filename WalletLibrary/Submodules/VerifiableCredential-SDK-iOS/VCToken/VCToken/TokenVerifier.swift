/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum TokenVerifierError: Error, Equatable {
    case malformedProtectedMessageInToken
}

struct TokenVerifier: TokenVerifying {
    
    private let cryptoOperations: CryptoOperating
    
    init(cryptoOperations: CryptoOperating = CryptoOperations()) {
        self.cryptoOperations = cryptoOperations
    }
    
    func verify<T>(token: JwsToken<T>, usingPublicKey key: JWK) throws -> Bool {
        
        guard let signature = token.signature else {
            return false
        }
        
        guard let encodedMessage = token.protectedMessage.data(using: .ascii) else {
            throw TokenVerifierError.malformedProtectedMessageInToken
        }
        
        let publicKey = try cryptoOperations.getPublicKey(fromJWK: key)
        
        return try cryptoOperations.verify(signature: signature,
                                           forMessage: encodedMessage,
                                           usingPublicKey: publicKey)
    }
}


