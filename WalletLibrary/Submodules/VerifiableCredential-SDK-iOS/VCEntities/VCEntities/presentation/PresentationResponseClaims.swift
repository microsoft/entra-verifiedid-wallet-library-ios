/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

struct PresentationResponseClaims: OIDCClaims {
    
    let issuer: String = VCEntitiesConstants.SELF_ISSUED_V2
        
    let subject: String
    
    let audience: String
    
    let vpTokenDescription: VPTokenResponseDescription?
    
    let nonce: String?
    
    let iat: Double?
    
    let exp: Double?
    
    init(subject: String = "",
                audience: String = "",
                vpTokenDescription: VPTokenResponseDescription? = nil,
                nonce: String? = "",
                iat: Double? = nil,
                exp: Double? = nil) {
        self.subject = subject
        self.audience = audience
        self.nonce = nonce
        self.iat = iat
        self.exp = exp
        self.vpTokenDescription = vpTokenDescription
    }
    
    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case subject = "sub"
        case vpTokenDescription = "_vp_token"
        case audience = "aud"
        case iat, exp, nonce
    }
}

typealias PresentationResponseToken = JwsToken<PresentationResponseClaims>
