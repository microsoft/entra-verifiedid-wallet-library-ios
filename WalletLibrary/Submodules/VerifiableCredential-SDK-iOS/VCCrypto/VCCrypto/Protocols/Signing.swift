/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Protocol that specifies operations of a signing algorithm.
public protocol Signing {
    
    /// Sign a message and return signature.
    func sign(message: Data, withSecret secret: VCCryptoSecret) throws -> Data
    
    /// Validate a signature based on the message hash.
    func isValidSignature(signature: Data, forMessage message: Data, usingPublicKey publicKey: PublicKey) throws -> Bool
    
    /// create public key from private key.
    func createPublicKey(forSecret secret: VCCryptoSecret) throws -> PublicKey
}
