/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public struct IssuanceResponseClaims: OIDCClaims {
    
    public let issuer: String = VCEntitiesConstants.SELF_ISSUED
        
    public let publicKeyThumbprint: String
    
    public let audience: String
    
    public let did: String
    
    public let publicJwk: ECPublicJwk?
    
    public let contract: String
    
    public let jti: String
    
    public let attestations: AttestationResponseDescriptor?
    
    public let pin: String?
    
    public let iat: Double?
    
    public let exp: Double?
    
    public init(publicKeyThumbprint: String = "",
                audience: String = "",
                did: String = "",
                publicJwk: ECPublicJwk? = nil,
                contract: String = "",
                jti: String = "",
                attestations: AttestationResponseDescriptor? = nil,
                pin: String? = nil,
                iat: Double? = nil,
                exp: Double? = nil) {
        self.publicKeyThumbprint = publicKeyThumbprint
        self.audience = audience
        self.did = did
        self.publicJwk = publicJwk
        self.contract = contract
        self.jti = jti
        self.attestations = attestations
        self.pin = pin
        self.iat = iat
        self.exp = exp
    }
    
    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case publicKeyThumbprint = "sub"
        case audience = "aud"
        case publicJwk = "sub_jwk"
        case contract, attestations, jti, did, iat, exp, pin
    }
}
