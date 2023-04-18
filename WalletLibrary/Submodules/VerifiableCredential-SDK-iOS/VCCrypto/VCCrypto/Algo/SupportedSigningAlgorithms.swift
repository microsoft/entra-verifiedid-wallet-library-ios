/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/


/// Algorithms that are currently supported by this library and which operations are implemented.
struct SupportedSigningAlgorithms {
    
    func algorithms() -> [String: SigningAlgorithm] {
        let es256k = SigningAlgorithm(curve: SupportedCurve.Secp256k1.rawValue,
                                      algorithm: ES256k(),
                                      supportedSigningOperations: [.Verification, .GetPublicKey, .Signing])
        
        let edDSA = SigningAlgorithm(curve: SupportedCurve.ED25519.rawValue,
                                     algorithm: EdDSA(),
                                     supportedSigningOperations: [.Verification])
        return [
            es256k.curve: es256k,
            edDSA.curve: edDSA
        ]
    }
}
