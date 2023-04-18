/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

enum JweDecoderError: Error {
    case unsupportedEncodingFormat
    case unableToInitializeJweToken
}

public class JweDecoder {
    
    private let json = JSONDecoder()
    
    public init() {}
    
    public func decode(token: String) throws -> JweToken {

        let components = token.components(separatedBy: ".")
        guard components.count == 5 else {
            throw JweDecoderError.unsupportedEncodingFormat
        }
        
        guard let headerData = Data(base64URLEncoded: components[0]) else {
            throw VCTokenError.unableToParseData
        }
        let headers = try json.decode(Header.self, from: headerData)
        
        guard let aad = components[0].data(using: .nonLossyASCII) else {
            throw VCTokenError.unableToParseData
        }

        guard let encryptedCek = Data(base64URLEncoded: components[1]) else {
            throw VCTokenError.unableToParseData
        }
        guard let iv = Data(base64URLEncoded: components[2]) else {
            throw VCTokenError.unableToParseData
        }
        guard let cipherText = Data(base64URLEncoded: components[3]) else {
            throw VCTokenError.unableToParseData
        }
        guard let authenticationTag = Data(base64URLEncoded: components[4]) else {
            throw VCTokenError.unableToParseData
        }

        // Wrap it all up
        return JweToken(headers: headers, aad: aad, encryptedKey: encryptedCek, iv: iv, ciperText: cipherText, authenticationTag: authenticationTag)
    }
}
