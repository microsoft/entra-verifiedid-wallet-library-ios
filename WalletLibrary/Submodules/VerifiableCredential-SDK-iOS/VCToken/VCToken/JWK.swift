/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

enum JwkError: Error {
    case invalidKeyValue
}

/// Runtime container for JSON Web Keys, in which key material is Base64URLEncoded
public struct JWK: Codable, Equatable {
    
    public let keyType: String
    public let keyId: String?
    public let key: Data?
    public let curve: String?
    public let use: String?
    public let x: Data?
    public let y: Data?
    public let d: Data?
    
    enum CodingKeys: String, CodingKey {
        case keyType = "kty"
        case keyId = "kid"
        case key = "k"
        case curve = "crv"
        case use, x, y, d
    }

    public init(keyType: String,
                keyId: String? = nil,
                key: Data? = nil,
                curve: String? = nil,
                use: String? = nil,
                x: Data? = nil,
                y: Data? = nil,
                d: Data? = nil) {
        self.keyType = keyType
        self.keyId = keyId
        self.key = key
        self.curve = curve
        self.use = use
        self.x = x
        self.y = y
        self.d = d
    }
    
    public init(from decoder: Decoder) throws {

        let values = try decoder.container(keyedBy: CodingKeys.self)
        func parseKeyIfPresent(_ key: KeyedDecodingContainer<JWK.CodingKeys>.Key) throws -> Data? {
            if let base64 = try values.decodeIfPresent(String.self, forKey: key) {
                guard let data = Data(base64URLEncoded: base64) else {
                    throw JwkError.invalidKeyValue
                }
                return data
            }
            return nil
        }

        keyType = try values.decode(String.self, forKey: .keyType)
        keyId = try values.decodeIfPresent(String.self, forKey: .keyId)
        key = try parseKeyIfPresent(.key)
        curve = try values.decodeIfPresent(String.self, forKey: .curve)
        use = try values.decodeIfPresent(String.self, forKey: .use)
        x = try parseKeyIfPresent(.x)
        y = try parseKeyIfPresent(.y)
        d = try parseKeyIfPresent(.d)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.keyType, forKey: .keyType)
        try container.encodeIfPresent(self.keyId, forKey: .keyId)
        try container.encodeIfPresent(self.key?.base64URLEncodedString(), forKey: .key)
        try container.encodeIfPresent(self.curve, forKey: .curve)
        try container.encodeIfPresent(self.use, forKey: .use)
        try container.encodeIfPresent(self.x?.base64URLEncodedString(), forKey: .x)
        try container.encodeIfPresent(self.y?.base64URLEncodedString(), forKey: .y)
        try container.encodeIfPresent(self.d?.base64URLEncodedString(), forKey: .d)
    }
}
