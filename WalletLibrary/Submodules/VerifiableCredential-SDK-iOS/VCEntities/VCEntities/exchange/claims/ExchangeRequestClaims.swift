/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct ExchangeRequestClaims: OIDCClaims {
    
    let issuer: String = VCEntitiesConstants.SELF_ISSUED
        
    let publicKeyThumbprint: String
    
    let audience: String
    
    let did: String
    
    let publicJwk: ECPublicJwk?
    
    let jti: String
    
    let iat: Double?
    
    let exp: Double?
    
    let exchangeableVc: String
    
    let recipientDid: String
    
    init(publicKeyThumbprint: String = "",
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

typealias ExchangeRequest = JwsToken<ExchangeRequestClaims>
