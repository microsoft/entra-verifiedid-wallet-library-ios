/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import CommonCrypto

enum HmacSha2AesCbcError: Error {
    case unsupportedMethod(name: String?)
    case invalidAuthenticationCode
}

public struct HmacSha2AesCbc {

    private let aes: Aes
    private let hmac: HmacSha2
    
    public init(methodName: String) throws {
        
        let (hmacAlg, _) = try HmacSha2AesCbc.props(for: methodName)
        self.hmac = try HmacSha2(algorithm: UInt32(hmacAlg))
        self.aes = Aes()
    }
    
    public func encrypt(plainText: Data, using aad: Data, iv: Data, with keys: (mac: EphemeralSecret, enc: EphemeralSecret)) throws -> (Data, Data) {
        
        let cipherText = try aes.encrypt(data: plainText, with: keys.enc, iv: iv)
        let mac = try self.authenticate(aad: aad, iv: iv, cipherText: cipherText, with: keys.mac)
        return (cipherText, mac)
    }
    
    public func decrypt(_ input: (cipherText: Data, mac: Data), using aad: Data, iv: Data, with keys: (mac: EphemeralSecret, enc: EphemeralSecret)) throws -> Data {
        
        // Validate the message authentication code
        let mac = try self.authenticate(aad: aad, iv: iv, cipherText: input.cipherText, with: keys.mac)
        if input.mac == mac {
            return try aes.decrypt(data: input.cipherText, with: keys.enc, iv: iv)
        }
        throw HmacSha2AesCbcError.invalidAuthenticationCode
    }
    
    public static func props(for methodName: String) throws -> (Int, Int) {

        let result: (hmacAlg: Int, keySize: Int)
        switch methodName {
        case "A128CBC-HS256":
            result.hmacAlg = kCCHmacAlgSHA256
            result.keySize = 16
        case "A192CBC-HS384":
            result.hmacAlg = kCCHmacAlgSHA384
            result.keySize = 24
        case "A256CBC-HS512":
            result.hmacAlg = kCCHmacAlgSHA512
            result.keySize = 32
        default:
            throw HmacSha2AesCbcError.unsupportedMethod(name: methodName)
        }
        return result
    }

    private func authenticate(aad: Data, iv: Data, cipherText: Data, with key: EphemeralSecret) throws -> Data {
        
        // Compose the message from which to generate the MAC
        let bitCount = UInt64(8 * aad.count).bigEndian
        let al = withUnsafeBytes(of: bitCount, Array.init)
        var message: Data = aad
        message.append(iv)
        message.append(cipherText)
        message.append(contentsOf: al)

        // Apply, and truncate
        let mac = try hmac.authenticate(message: message, with: key)
        return mac.prefix(key.value.count)
    }
}
