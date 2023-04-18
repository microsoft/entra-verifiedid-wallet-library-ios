/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
#if canImport(VCCrypto)
    import VCCrypto
#endif

enum PbesJweError: Error {
    case encodingError
    case invalidSaltInput
    case invalidAlgorithm
    case invalidEncryptionMethod
    case unauthenticatable
}

/// Implementation of password-based encryption scheme for JSON Web Encryption
public struct PbesJwe {

    private struct Constants {
        static let InitializationVectorByteSize = 16
    }
    
    private let aes = Aes()
    private let pbkdf = Pbkdf()

    public init() {}

    public func encrypt(_ plainText: Data, with password: String, using headers: Header) throws -> JweToken {

        // Generate a content-encryption key
        guard let method = headers.encryptionMethod else {
            throw PbesJweError.invalidEncryptionMethod
        }
        let (_, keySize) = try HmacSha2AesCbc.props(for: method)
        let cek = try EphemeralSecret(size: (keySize*2))
        let keys = (cek.prefix(keySize), cek.suffix(keySize))

        // Generate the additional authentication data, and the initialization vector, respectively
        guard let aad = try JSONEncoder().encode(headers).base64URLEncodedString().data(using: .nonLossyASCII) else {
            throw PbesJweError.encodingError
        }
        let iv = try EphemeralSecret(size: Constants.InitializationVectorByteSize)

        // Generate the cipher text and message authentication code
        guard let alg = headers.algorithm else {
            throw PbesJweError.invalidAlgorithm
        }
        let hmac = try HmacSha2AesCbc(methodName: method)
        let (cipherText, mac) = try hmac.encrypt(plainText: plainText, using: aad, iv: iv.value, with: keys)

        // Derive the key-encrypting key from the password
        guard let p2c = headers.pbes2Count,
              let p2s = headers.pbes2SaltInput else {
            throw PbesJweError.invalidSaltInput
        }
        let kek = try pbkdf.derive(from: password, withSaltInput: Data(base64URLEncoded: p2s)!, forAlgorithm: alg, rounds: UInt32(p2c))
        
        // Wrap the content-encryption key with the key-encryption key
        let encryptedKey = try aes.wrap(key: cek, with: kek)
        
        // Pull it all together
        let token = JweToken(headers: headers, aad: aad, encryptedKey: encryptedKey, iv: iv.value, ciperText: cipherText, authenticationTag: mac)
        return token
    }

    public func decrypt(_ token: JweToken, with password: String) throws -> Data {

        // Derive the key-encrypting key from the password
        guard let alg = token.headers.algorithm else {
            throw PbesJweError.invalidAlgorithm
        }
        guard let p2c = token.headers.pbes2Count,
              let p2s = token.headers.pbes2SaltInput else {
            throw PbesJweError.invalidSaltInput
        }
        let kek = try pbkdf.derive(from: password, withSaltInput: Data(base64URLEncoded: p2s)!, forAlgorithm: alg, rounds: UInt32(p2c))

        // Unwrap the content-encryption key
        guard let method = token.headers.encryptionMethod else {
            throw PbesJweError.invalidEncryptionMethod
        }
        let (_, keySize) = try HmacSha2AesCbc.props(for: method)
        let unwrapped = try aes.unwrap(wrapped: token.encryptedKey, using: kek)
        let cek = try EphemeralSecret(with: unwrapped)
        let keys = (cek.prefix(keySize), cek.suffix(keySize))

        // Authenticate and decrypt the plaintext
        let hmac = try HmacSha2AesCbc(methodName: method)
        let plainText = try hmac.decrypt((token.ciperText, token.authenticationTag), using: token.aad, iv: token.iv, with: keys)
        return plainText
    }
}
