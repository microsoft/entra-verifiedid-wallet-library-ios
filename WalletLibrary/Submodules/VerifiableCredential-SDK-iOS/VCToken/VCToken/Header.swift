/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct Header: Codable {
    public let type: String?
    public let algorithm: String?
    public let encryptionMethod: String?
    public let jsonWebKey: String?
    public let keyId: String?
    public let contentType: String?
    public let pbes2SaltInput: String?
    public let pbes2Count: UInt?

    public init(type: String? = nil,
                algorithm: String? = nil,
                encryptionMethod: String? = nil,
                jsonWebKey: String? = nil,
                keyId: String? = nil,
                contentType: String? = nil,
                pbes2SaltInput: String? = nil,
                pbes2Count: UInt? = nil) {
        self.type = type
        self.algorithm = algorithm
        self.encryptionMethod = encryptionMethod
        self.jsonWebKey = jsonWebKey
        self.keyId = keyId
        self.contentType = contentType
        self.pbes2SaltInput = pbes2SaltInput
        self.pbes2Count = pbes2Count
    }

    public enum CodingKeys: String, CodingKey {
        case type = "typ"
        case algorithm = "alg"
        case jsonWebKey = "jwk"
        case keyId = "kid"
        case contentType = "cty"
        case encryptionMethod = "enc"
        case pbes2SaltInput = "p2s"
        case pbes2Count = "p2c"
    }

    // Note: implementing decode and encode to work around a compiler issue causing a EXC_BAD_ACCESS.
    // See: https://bugs.swift.org/browse/SR-7090
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        algorithm = try values.decodeIfPresent(String.self, forKey: .algorithm)
        encryptionMethod = try values.decodeIfPresent(String.self, forKey: .encryptionMethod)
        jsonWebKey = try values.decodeIfPresent(String.self, forKey: .jsonWebKey)
        keyId = try values.decodeIfPresent(String.self, forKey: .keyId)
        contentType = try values.decodeIfPresent(String.self, forKey: .contentType)
        pbes2SaltInput = try values.decodeIfPresent(String.self, forKey: .pbes2SaltInput)
        pbes2Count = try values.decodeIfPresent(UInt.self, forKey: .pbes2Count)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(algorithm, forKey: .algorithm)
        try container.encodeIfPresent(encryptionMethod, forKey: .encryptionMethod)
        try container.encodeIfPresent(jsonWebKey, forKey: .jsonWebKey)
        try container.encodeIfPresent(keyId, forKey: .keyId)
        try container.encodeIfPresent(contentType, forKey: .contentType)
        try container.encodeIfPresent(pbes2SaltInput, forKey: .pbes2SaltInput)
        try container.encodeIfPresent(pbes2Count, forKey: .pbes2Count)
    }
}
