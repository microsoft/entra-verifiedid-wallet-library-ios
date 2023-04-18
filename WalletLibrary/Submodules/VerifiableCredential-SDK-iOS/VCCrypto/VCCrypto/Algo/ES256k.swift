/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

/// Algorithm that hashes message and signs/verifies using Secp256k1
struct ES256k: Signing {
    
    /// Supported hashing algorithm for ES256k
    let hashAlgorithm: Hashing
    
    /// Supported curve for ES256k
    let curveAlgorithm: Signing
    
    init(hashAlgorithm: Hashing = Sha256(),
         curveAlgorithm: Signing = Secp256k1()) {
        self.hashAlgorithm = hashAlgorithm
        self.curveAlgorithm = curveAlgorithm
        
    }
    
    /// Hashes and signs a message
    func sign(message: Data, withSecret secret: VCCryptoSecret) throws -> Data {
        let hashedMessage = hashAlgorithm.hash(data: message)
        return try curveAlgorithm.sign(message: hashedMessage, withSecret: secret)
    }
    
    /// Hashes message and validates the signature
    func isValidSignature(signature: Data,
                          forMessage message: Data,
                          usingPublicKey publicKey: PublicKey) throws -> Bool {
        let hashedMessage = hashAlgorithm.hash(data: message)
        return try curveAlgorithm.isValidSignature(signature: signature, forMessage: hashedMessage, usingPublicKey: publicKey)
       
    }
    
    /// Create public key using secp256k1 curve and return PublicKey
    func createPublicKey(forSecret secret: VCCryptoSecret) throws -> PublicKey {
        return try curveAlgorithm.createPublicKey(forSecret: secret)
    }
}

