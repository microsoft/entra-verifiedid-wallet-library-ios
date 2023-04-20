/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import CommonCrypto

enum PbkdfError : Error {
    case keyDerivationError
    case invalidAlgorithmNameError(name:String)
}

public struct Pbkdf {
    
    public init() { }

    public func derive(from password: String, withSaltInput p2s: Data, forAlgorithm algorithm: String, rounds: UInt32) throws -> VCCryptoSecret {
        
        // Determine the algorithm, and key size
        let size: size_t, pseudoRandomAlgorithm: CCPseudoRandomAlgorithm
        switch (algorithm) {
        case "PBES2-HS256+A128KW":
            pseudoRandomAlgorithm = CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256)
            size = 16
        case "PBES2-HS384+A192KW":
            pseudoRandomAlgorithm = CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA384)
            size = 24
        case "PBES2-HS512+A256KW":
            pseudoRandomAlgorithm = CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512)
            size = 32
        default:
            throw PbkdfError.invalidAlgorithmNameError(name:algorithm)
        }

        // Construct the salt, c.f. https://datatracker.ietf.org/doc/html/rfc7517#appendix-C.4
        guard var salt = algorithm.data(using: .utf8) else {
            throw PbkdfError.invalidAlgorithmNameError(name:algorithm)
        }
        salt.append(UInt8(0))
        salt.append(p2s)
        
        // Derive the key
        var derived = Data(count: size)
        defer {
            derived.withUnsafeMutableBytes { (derivedPtr) in
                memset_s(derivedPtr.baseAddress, size, 0, size)
                return
            }
        }
        try derived.withUnsafeMutableBytes { (derivedPtr: UnsafeMutableRawBufferPointer) in
            let derivedBytes = derivedPtr.bindMemory(to: UInt8.self)

            try salt.withUnsafeBytes { (saltPtr: UnsafeRawBufferPointer) in
                let saltBytes = saltPtr.bindMemory(to: UInt8.self)

                let status = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
                                                  password,
                                                  password.utf8.count,
                                                  saltBytes.baseAddress,
                                                  saltBytes.count,
                                                  pseudoRandomAlgorithm,
                                                  rounds,
                                                  derivedBytes.baseAddress,
                                                  derivedBytes.count)
                guard status == kCCSuccess else {
                    throw PbkdfError.keyDerivationError
                }
            }
        }
        return EphemeralSecret(with: derived)
    }
}
