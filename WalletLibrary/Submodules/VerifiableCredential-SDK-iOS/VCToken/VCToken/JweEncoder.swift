/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

public enum JweFormat {
    case compact
}

public class JweEncoder {

    private let json = JSONEncoder()
    
    public init() {}
    
    public func encode(_ token: JweToken, format: JweFormat = JweFormat.compact) throws -> String {
        switch format {
        case .compact:
            return try encodeUsingCompactFormat(token: token)
        }
    }
    
    private func encodeUsingCompactFormat(token: JweToken) throws -> String {
        
        var encoded = try json.encode(token.headers).base64URLEncodedString()
        encoded.append(".")
        encoded.append(token.encryptedKey.base64URLEncodedString())
        encoded.append(".")
        encoded.append(token.iv.base64URLEncodedString())
        encoded.append(".")
        encoded.append(token.ciperText.base64URLEncodedString())
        encoded.append(".")
        encoded.append(token.authenticationTag.base64URLEncodedString())
        return encoded
    }
}
