/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import CryptoKit

enum ED25519Error: Error {
    case notImplemented
}

/// Algorithm that hashes message and signs/verifies using ED25519.
struct EdDSA: Signing {
    
    /// Not Implemented
    func sign(message: Data, withSecret secret: VCCryptoSecret) throws -> Data {
        throw ED25519Error.notImplemented
    }
    
    /// Hashes message and validates the signature
    func isValidSignature(signature: Data, forMessage message: Data, usingPublicKey publicKey: PublicKey) throws -> Bool {
        let pubKey = try Curve25519.Signing.PublicKey(rawRepresentation: publicKey.uncompressedValue)
        return pubKey.isValidSignature(signature, for: message)
    }
    
    /// Not Implemented
    func createPublicKey(forSecret secret: VCCryptoSecret) throws -> PublicKey {
        throw ED25519Error.notImplemented
    }

}
