/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public struct ExchangeRequestClaims: OIDCClaims {
    
    public let issuer: String = VCEntitiesConstants.SELF_ISSUED
        
    public let publicKeyThumbprint: String
    
    public let audience: String
    
    public let did: String
    
    public let publicJwk: ECPublicJwk?
    
    public let jti: String
    
    public let iat: Double?
    
    public let exp: Double?
    
    public let exchangeableVc: String
    
    public let recipientDid: String
    
    public init(publicKeyThumbprint: String = "",
                audience: String = "",
                did: String = "",
                publicJwk: ECPublicJwk? = nil,
                jti: String = "",
                iat: Double? = nil,
                exp: Double? = nil,
                exchangeableVc: String = "",
                recipientDid: String = "") {
        self.publicKeyThumbprint = publicKeyThumbprint
        self.audience = audience
        self.did = did
        self.publicJwk = publicJwk
        self.jti = jti
        self.iat = iat
        self.exp = exp
        self.exchangeableVc = exchangeableVc
        self.recipientDid = recipientDid
    }
    
    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case publicKeyThumbprint = "sub"
        case audience = "aud"
        case publicJwk = "sub_jwk"
        case exchangeableVc = "vc"
        case recipientDid = "recipient"
        case jti, did, iat, exp
    }
}

public typealias ExchangeRequest = JwsToken<ExchangeRequestClaims>
