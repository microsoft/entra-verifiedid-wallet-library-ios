/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

struct VerifiablePresentationClaims: OIDCClaims {
    let vpId: String
    
    let verifiablePresentation: VerifiablePresentationDescriptor
    
    let issuerOfVp: String
    
    let audience: String
    
    let iat: Double
    
    let nbf: Double
    
    let exp: Double
    
    let nonce: String?
    
    enum CodingKeys: String, CodingKey {
        case issuerOfVp = "iss"
        case audience = "aud"
        case vpId = "jti"
        case verifiablePresentation = "vp"
        case iat, exp, nonce, nbf
    }
    
    init(vpId: String = "",
                verifiablePresentation: VerifiablePresentationDescriptor?,
                issuerOfVp: String = "",
                audience: String = "",
                iat: Double = 0,
                nbf: Double = 0,
                exp: Double = 0,
                nonce: String? = "") {
        self.vpId = vpId
        self.verifiablePresentation = verifiablePresentation ?? VerifiablePresentationDescriptor(context: [], type: [], verifiableCredential: [])
        self.issuerOfVp = issuerOfVp
        self.audience = audience
        self.iat = iat
        self.nbf = nbf
        self.exp = exp
        self.nonce = nonce
    }
}

typealias VerifiablePresentation = JwsToken<VerifiablePresentationClaims>
