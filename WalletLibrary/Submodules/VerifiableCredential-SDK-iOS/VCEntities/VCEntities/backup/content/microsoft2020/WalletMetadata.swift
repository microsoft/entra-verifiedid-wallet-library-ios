/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
#if canImport(VCToken)
    import VCToken
#endif

open class WalletMetadata: Codable {
    enum CodingKeys: String, CodingKey {
        case seed
    }

    public var seed: Data
    
    public init(with seed:Data) {
        self.seed = seed
    }

    public required init(from decoder:Decoder) throws {
        
        let container = try decoder.container(keyedBy: Self.CodingKeys)
        let string = try container.decode(String.self, forKey: .seed)
        
        // Now, parse the string as a JWK
        let jwk = try JSONDecoder().decode(JWK.self, from: string.data(using: .utf8)!)
        self.seed = jwk.key!
    }
    
    public func encode(to encoder: Encoder) throws {
        
        // Wrap the seed value in a JWK and encode to a string
        let jwk = JWK(keyType: "oct", key: self.seed)
        let string = try String(data: JSONEncoder().encode(jwk), encoding: .utf8)!
        
        var container = encoder.container(keyedBy: Self.CodingKeys)
        try container.encode(string, forKey: .seed)
    }
}
