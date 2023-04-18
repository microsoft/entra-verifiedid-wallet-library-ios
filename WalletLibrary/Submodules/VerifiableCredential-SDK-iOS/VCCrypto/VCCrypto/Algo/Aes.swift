/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import CommonCrypto

enum AesError : Error {
    case keyWrapError
    case keyUnwrapError
    case invalidSecret
    case cryptoError(operation:CCOperation, status:CCCryptorStatus)
}

public struct Aes {
    
    // AES processes inputs in blocks of 128 bits (16 bytes)
    internal let blockSize = size_t(16)

    private let keyWrapAlg = CCWrappingAlgorithm(kCCWRAPAES)
    
    public init() {}
    
    public func wrap(key: VCCryptoSecret, with kek: VCCryptoSecret) throws -> Data {

        // Look for an early out
        guard key is Secret, kek is Secret else {
            throw AesError.invalidSecret
        }
        var wrappedSize: Int = 0
        try (key as! Secret).withUnsafeBytes { (keyPtr: UnsafeRawBufferPointer) in
            let keySize = keyPtr.bindMemory(to: UInt8.self).count
            wrappedSize = CCSymmetricWrappedSize(keyWrapAlg, keySize)
        }
        var wrapped = Data(repeating: 0, count: wrappedSize)
        try wrapped.withUnsafeMutableBytes({ (wrappedPtr: UnsafeMutableRawBufferPointer) in
            let wrappedBytes = wrappedPtr.bindMemory(to: UInt8.self)
            
            try (key as! Secret).withUnsafeBytes { (keyPtr: UnsafeRawBufferPointer) in
                let keyBytes = keyPtr.bindMemory(to: UInt8.self)
                
                try (kek as! Secret).withUnsafeBytes { (kekPtr: UnsafeRawBufferPointer) in
                    let kekBytes = kekPtr.bindMemory(to: UInt8.self)
                    let status = CCSymmetricKeyWrap(keyWrapAlg,
                                                    CCrfc3394_iv,
                                                    CCrfc3394_ivLen,
                                                    kekBytes.baseAddress,
                                                    kekBytes.count,
                                                    keyBytes.baseAddress,
                                                    keyBytes.count,
                                                    wrappedBytes.baseAddress,
                                                    &wrappedSize)
                    guard status == kCCSuccess else {
                        throw AesError.keyWrapError
                    }
                }
            }
        })
        return wrapped
    }
    
    public func unwrap(wrapped: Data, using kek: VCCryptoSecret) throws -> VCCryptoSecret {

        // Look for an early out
        guard kek is Secret else {
            throw AesError.invalidSecret
        }

        var unwrappedSize = CCSymmetricUnwrappedSize(keyWrapAlg, wrapped.count)
        var unwrapped = Data(repeating: 0, count: unwrappedSize)
        defer {
            unwrapped.withUnsafeMutableBytes { (unwrappedPtr) in
                memset_s(unwrappedPtr.baseAddress, unwrappedSize, 0, unwrappedSize)
                return
            }
        }

        try unwrapped.withUnsafeMutableBytes { (unwrappedPtr: UnsafeMutableRawBufferPointer) in
            let unwrappedBytes = unwrappedPtr.bindMemory(to: UInt8.self)
            
            try wrapped.withUnsafeBytes { (wrappedPtr: UnsafeRawBufferPointer) in
                let wrappedBytes = wrappedPtr.bindMemory(to: UInt8.self)
                
                try (kek as! Secret).withUnsafeBytes { (kekPtr: UnsafeRawBufferPointer) in
                    let kekBytes = kekPtr.bindMemory(to: UInt8.self)
                    let status = CCSymmetricKeyUnwrap(keyWrapAlg,
                                                      CCrfc3394_iv,
                                                      CCrfc3394_ivLen,
                                                      kekBytes.baseAddress,
                                                      kekBytes.count,
                                                      wrappedBytes.baseAddress,
                                                      wrappedBytes.count,
                                                      unwrappedBytes.baseAddress,
                                                      &unwrappedSize)
                    guard status == kCCSuccess else {
                        throw AesError.keyUnwrapError
                    }
                }
            }
        }
        return EphemeralSecret(with: unwrapped)
    }

    public func encrypt(data: Data, with key: VCCryptoSecret, iv: Data) throws -> Data {

        // If the input isn't perfectly aligned to the AES block size, then padding is required
        let options = data.count % blockSize == 0 ? CCOptions(0) : CCOptions(kCCOptionPKCS7Padding)
        return try self.apply(operation: CCOperation(kCCEncrypt), withOptions: options, to: data, using: key, iv: iv)
    }
    
    public func decrypt(data: Data, with key: VCCryptoSecret, iv: Data) throws -> Data {
        return try self.apply(operation: CCOperation(kCCDecrypt), withOptions: CCOptions(kCCOptionPKCS7Padding), to: data, using: key, iv: iv)
    }

    private func apply(operation: CCOperation, withOptions options: CCOptions, to data: Data, using key: VCCryptoSecret, iv: Data) throws -> Data {

        // Look for an early out
        guard key is Secret else { throw AesError.invalidSecret }

        // Allocate the output buffer
        var outputSize = size_t(data.count)
        let modulo = data.count % blockSize
        if modulo > 0 {
            outputSize += size_t(blockSize - modulo)
        }
        var output = [UInt8](repeating: 0, count: outputSize)
        
        try (key as! Secret).withUnsafeBytes { (keyPtr: UnsafeRawBufferPointer) in
            let keyBytes = keyPtr.bindMemory(to: UInt8.self)

            try iv.withUnsafeBytes { (ivPtr: UnsafeRawBufferPointer) in
                let ivBytes = ivPtr.bindMemory(to: UInt8.self)
                
                try data.withUnsafeBytes { (dataPtr: UnsafeRawBufferPointer) in
                    let dataBytes = dataPtr.bindMemory(to: UInt8.self)
                    
                    let status = CCCrypt(operation,
                                         CCAlgorithm(kCCAlgorithmAES),
                                         options,
                                         keyBytes.baseAddress,
                                         keyBytes.count,
                                         ivBytes.baseAddress,
                                         dataBytes.baseAddress,
                                         dataBytes.count,
                                         &output,
                                         outputSize,
                                         &outputSize)
                    if status == kCCSuccess {
                        output.removeSubrange(outputSize..<output.count)
                    } else {
                        throw AesError.cryptoError(operation:operation, status:status)
                    }
                }
            }
        }
        return Data(output)
    }
}
