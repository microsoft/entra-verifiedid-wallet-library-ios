/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct PresentationResponseClaims: OIDCClaims {
    
    let issuer: String = VCEntitiesConstants.SELF_ISSUED_V2
        
    let subject: String
    
    let audience: String
    
    let vpTokenDescription: [VPTokenResponseDescription]
    
    let nonce: String?
    
    let iat: Int?
    
    let exp: Int?
    
    init(subject: String = "",
         audience: String = "",
         vpTokenDescription: [VPTokenResponseDescription] = [],
         nonce: String? = "",
         iat: Int? = nil,
         exp: Int? = nil) {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(issuer, forKey: .issuer)
        try container.encode(subject, forKey: .subject)
        try container.encode(audience, forKey: .audience)
        try container.encode(iat, forKey: .iat)
        try container.encode(exp, forKey: .exp)
        try container.encode(nonce, forKey: .nonce)
        if vpTokenDescription.count == 1,
           let onlyVpToken = vpTokenDescription.first
        {
            try container.encode(onlyVpToken, forKey: .vpTokenDescription)
        }
        else
        {
            try container.encode(self.vpTokenDescription, forKey: .vpTokenDescription)
        }
    }
}

typealias PresentationResponseToken = JwsToken<PresentationResponseClaims>
