/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

public enum JwsFormat {
    case compact
}

public class JwsEncoder {
    
    private let encoder = JSONEncoder()
    
    public init() {}
    
    public func encode<T>(_ token: JwsToken<T>, format: JwsFormat = JwsFormat.compact) throws -> String {
        switch format {
        case .compact:
            return try encodeUsingCompactFormat(token: token)
        }
    }
    
    private func encodeUsingCompactFormat<T>(token: JwsToken<T>) throws -> String {
        
        if let encodedToken = token.rawValue {
            return encodedToken
        }
        
        var compactToken = token.protectedMessage
        
        if let signature = token.signature?.base64URLEncodedString() {
            compactToken = compactToken + "." + signature
        }
        
        return compactToken
    }
}
