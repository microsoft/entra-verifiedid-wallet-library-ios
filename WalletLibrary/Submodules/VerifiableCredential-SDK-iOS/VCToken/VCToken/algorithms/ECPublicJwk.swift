/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// TODO: deprecate entity for JWK
struct ECPublicJwk: Codable, Equatable {
    let keyType: String
    let keyId: String?
    let use: String?
    let keyOperations: [String]?
    let algorithm: String?
    let curve: String
    let x: String
    let y: String?
    
    enum CodingKeys: String, CodingKey {
        case keyType = "kty"
        case keyId = "kid"
        case keyOperations = "key_ops"
        case algorithm = "alg"
        case curve = "crv"
        case use, x, y
    }
    
    init(x: String, y: String, keyId: String) {
        self.keyType = "EC"
        self.keyId = keyId
        self.use = "sig"
        self.keyOperations = ["verify"]
        self.algorithm = "ES256K"
        self.curve = "secp256k1"
        self.x = x
        self.y = y
    }
    
    init(withPublicKey key: Secp256k1PublicKey, withKeyId kid: String) {
        let x = key.x.base64URLEncodedString()
        let y = key.y.base64URLEncodedString()
        self.init(x: x, y: y, keyId: kid)
    }
    
    func toJWK() -> JWK
    {
        var encodedY: Data? = nil
        if let y = y {
            encodedY = Data(base64URLEncoded: y)
        }
        
        return JWK(keyType: keyType,
                   keyId: keyId,
                   curve: curve,
                   use: use,
                   x: Data(base64URLEncoded: x),
                   y: encodedY)
    }
    
    func getMinimumAlphabeticJwk() -> String {
        
        var encodedJwk = "{\"crv\":\"\(curve)\",\"kty\":\"\(keyType)\",\"x\":\"\(x)\""
        
        /// ED25519 keys do not have y value, but Secp256k1 do.
        if let y = y {
            encodedJwk.append(",\"y\":\"\(y)\"}")
        }
        
        return encodedJwk
    }
    
    func getThumbprint() throws -> String {
        
        let hashAlgorithm = Sha256()
        
        guard let encodedJwk = self.getMinimumAlphabeticJwk().data(using: .utf8) else {
            throw TokenError.UnableToParseToken(component: "encodedJwk")
        }
        
        let hash = hashAlgorithm.hash(data: encodedJwk)
        return hash.base64URLEncodedString()
    }
}
