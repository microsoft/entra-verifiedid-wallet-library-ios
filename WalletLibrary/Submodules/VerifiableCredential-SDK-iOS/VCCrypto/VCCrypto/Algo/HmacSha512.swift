/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import CommonCrypto

@available(*, deprecated, message: "Superceded by HmacSha2")
public struct HmacSha512 {

    public init() { }
    
    /// Authenticate a message
    /// - Parameters:
    ///   - message: The message to authenticate
    ///   - secret: The secret used for authentication
    /// - Returns: The authentication code for the message
    public func authenticate(message: Data, withSecret secret: VCCryptoSecret) throws -> Data {
        let hmac = try HmacSha2(algorithm: UInt32(kCCHmacAlgSHA512))
        return try hmac.authenticate(message: message, with: secret)
    }
    
    /// Verify that the authentication code is valid
    /// - Parameters:
    ///   - mac: The authentication code
    ///   - message: The message
    ///   - secret: The secret used
    /// - Returns: True if the authentication code is valid
    public func isValidAuthenticationCode(_ mac: Data, authenticating message: Data, withSecret secret: VCCryptoSecret) throws -> Bool {
        let hmac = try HmacSha2(algorithm: UInt32(kCCHmacAlgSHA512))
        return try hmac.validate(mac, authenticating: message, with: secret)
    }
}
