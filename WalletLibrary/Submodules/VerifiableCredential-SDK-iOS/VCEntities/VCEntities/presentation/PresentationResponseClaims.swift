/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public struct PresentationResponseClaims: OIDCClaims {
    
    public let issuer: String = VCEntitiesConstants.SELF_ISSUED_V2
        
    public let subject: String
    
    public let audience: String
    
    public let vpTokenDescription: VPTokenResponseDescription?
    
    public let nonce: String?
    
    public let iat: Double?
    
    public let exp: Double?
    
    public init(subject: String = "",
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

public typealias PresentationResponseToken = JwsToken<PresentationResponseClaims>
