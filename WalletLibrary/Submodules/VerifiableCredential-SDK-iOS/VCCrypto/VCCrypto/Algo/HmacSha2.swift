/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import CommonCrypto

enum HmacSha2Error: Error {
    case invalidMessage
    case invalidSecret
    case invalidAlgorithm
}

public struct HmacSha2 {

    private let macSize: Int
    private let algorithm: UInt32
    
    public init(algorithm: UInt32) throws {
        switch (algorithm) {
        case UInt32(kCCHmacAlgSHA256):
            self.macSize = Int(CC_SHA256_DIGEST_LENGTH)
        case UInt32(kCCHmacAlgSHA384):
            self.macSize = Int(CC_SHA384_DIGEST_LENGTH)
        case UInt32(kCCHmacAlgSHA512):
            self.macSize = Int(CC_SHA512_DIGEST_LENGTH)
        default:
            throw HmacSha2Error.invalidAlgorithm
        }
        self.algorithm = algorithm
    }
    
    /// Authenticate a message
    /// - Parameters:
    ///   - message: The message to authenticate
    ///   - secret: The secret used for authentication
    /// - Returns: The authentication code for the message
    public func authenticate(message: Data, with secret: VCCryptoSecret) throws -> Data {

        // Look for an early out
        guard message.count > 0 else { throw HmacSha2Error.invalidMessage }
        guard secret is Secret else { throw HmacSha2Error.invalidSecret }

        // Apply
        let ccHmacAlg = self.algorithm
        var mac: [UInt8] = [UInt8](repeating: 0, count:self.macSize)
        try message.withUnsafeBytes { (messagePtr: UnsafeRawBufferPointer) in
            let messageBytes = messagePtr.bindMemory(to: UInt8.self)
            
            try (secret as! Secret).withUnsafeBytes { (secretPtr: UnsafeRawBufferPointer) in
                let secretBytes = secretPtr.bindMemory(to: UInt8.self)
                
                CCHmac(ccHmacAlg, secretBytes.baseAddress, secretBytes.count, messageBytes.baseAddress, messageBytes.count, &mac)
            }
        }
        return Data(mac)
    }

    /// Verify that the authentication code is valid
    /// - Parameters:
    ///   - mac: The authentication code
    ///   - message: The message
    ///   - secret: The secret used
    /// - Returns: True if the authentication code is valid
    public func validate(_ mac: Data, authenticating message: Data, with secret: VCCryptoSecret) throws -> Bool {
        
        let authentication = try self.authenticate(message: message, with: secret)
        return mac == authentication
    }
}
