/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum CryptoOperationsError: Error {
    case invalidPublicKey
    case signingAlgorithmNotSupported(String?)
    case signingAlgorithmDoesNotSupportGetPublicKey
    case signingAlgorithmDoesNotSupportSigning
    case signingAlgorithmDoesNotSupportVerification
}

/// Operations that are involved in verification cryptographic operations..
struct CryptoOperations: CryptoOperating {
    
    private let signingAlgorithms: [String: SigningAlgorithm]
    
    init(signingAlgorithms: [String: SigningAlgorithm] = [:]) {
        var supportedAlgorithms = SupportedSigningAlgorithms().algorithms()
        
        /// Merge injected algorithms with support algorithms.
        /// If merge conflict occurs, choose built in supported algorithm.
        supportedAlgorithms.merge(signingAlgorithms) { first, second in return first }
        
        self.signingAlgorithms = supportedAlgorithms
    }
    
    /// Only supports Secp256k1 signing.
    func sign(message: Data,
              usingSecret secret: VCCryptoSecret,
              algorithm: String = SupportedCurve.Secp256k1.rawValue) throws -> Data {
        
        guard let signingAlgo = signingAlgorithms[algorithm.uppercased()] else {
            throw CryptoOperationsError.signingAlgorithmNotSupported(algorithm)
        }
        
        guard signingAlgo.supportedSigningOperations.contains(.Signing) else {
            throw CryptoOperationsError.signingAlgorithmDoesNotSupportSigning
        }
        
        return try signingAlgo.algorithm.sign(message: message, withSecret: secret)
    }
    
    /// Only support Secp256k1 public key retrieval.
    func getPublicKey(fromSecret secret: VCCryptoSecret,
                      algorithm: String = SupportedCurve.Secp256k1.rawValue) throws -> PublicKey {
        
        guard let signingAlgo = signingAlgorithms[algorithm.uppercased()] else {
            throw CryptoOperationsError.signingAlgorithmNotSupported(algorithm)
        }
        
        guard signingAlgo.supportedSigningOperations.contains(.GetPublicKey) else {
            throw CryptoOperationsError.signingAlgorithmDoesNotSupportGetPublicKey
        }
        
        return try signingAlgo.algorithm.createPublicKey(forSecret: secret)
    }
    
    /// Get the public key representation of the key from the JWK format if the algorithm is supported.
    func getPublicKey(fromJWK key: JWK) throws -> PublicKey {
        
        if let algoName = key.curve?.uppercased(),
           let signer = signingAlgorithms[algoName] {
            return try signer.algorithm.createPublicKey(fromJWK: key)
        }
        
        throw CryptoOperationsError.signingAlgorithmNotSupported(key.curve)
    }
    
    /// Verify signature for the message using the public key if public key algorithm is supported.
    func verify(signature: Data,
                forMessage message: Data,
                usingPublicKey publicKey: PublicKey) throws -> Bool {
        
        guard let signingAlgo = signingAlgorithms[publicKey.algorithm.uppercased()] else {
            throw CryptoOperationsError.signingAlgorithmNotSupported(publicKey.algorithm)
        }
        
        guard signingAlgo.supportedSigningOperations.contains(.Verification) else {
            throw CryptoOperationsError.signingAlgorithmDoesNotSupportVerification
        }

        return try signingAlgo.algorithm.isValidSignature(signature: signature, forMessage: message, usingPublicKey: publicKey)
    }
}
