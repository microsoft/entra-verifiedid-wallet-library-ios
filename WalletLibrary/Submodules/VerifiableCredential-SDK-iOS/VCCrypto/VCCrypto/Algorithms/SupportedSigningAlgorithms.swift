/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/


/// Algorithms that are currently supported by this library and which operations are implemented.
struct SupportedSigningAlgorithms {
    
    func algorithms() -> [String: SigningAlgorithm] {
        let secp256k1 = SigningAlgorithm(curve: SupportedCurve.SECP256K1.rawValue,
                                         algorithm: ES256k(),
                                         supportedSigningOperations: [.Verification, .GetPublicKey, .Signing])
        
        let es256k = SigningAlgorithm(curve: SupportedCurve.ES256K.rawValue,
                                      algorithm: ES256k(),
                                      supportedSigningOperations: [.Verification, .GetPublicKey, .Signing])
        
        let secp256k = SigningAlgorithm(curve: SupportedCurve.SECP256K.rawValue,
                                        algorithm: ES256k(),
                                        supportedSigningOperations: [.Verification, .GetPublicKey, .Signing])
        
        let edDSA = SigningAlgorithm(curve: SupportedCurve.ED25519.rawValue,
                                     algorithm: EdDSA(),
                                     supportedSigningOperations: [.Verification])
        
        let p256 = SigningAlgorithm(curve: SupportedCurve.P256.rawValue,
                                    algorithm: ES256(),
                                    supportedSigningOperations: [.Verification, .GetPublicKey, .Signing])
        
        let es256 = SigningAlgorithm(curve: "ES256",
                                    algorithm: ES256(),
                                    supportedSigningOperations: [.Verification, .GetPublicKey, .Signing])
        
        return [
            secp256k1.curve: secp256k1,
            es256k.curve: es256k,
            edDSA.curve: edDSA,
            p256.curve: p256,
            es256.curve: es256,
            secp256k.curve: secp256k
        ]
    }
}
