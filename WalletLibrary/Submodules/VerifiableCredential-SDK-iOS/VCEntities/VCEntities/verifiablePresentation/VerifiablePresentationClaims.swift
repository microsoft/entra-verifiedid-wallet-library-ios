/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public struct VerifiablePresentationClaims: OIDCClaims {
    public let vpId: String
    
    public let verifiablePresentation: VerifiablePresentationDescriptor
    
    public let issuerOfVp: String
    
    public let audience: String
    
    public let iat: Double
    
    public let nbf: Double
    
    public let exp: Double
    
    public let nonce: String?
    
    enum CodingKeys: String, CodingKey {
        case issuerOfVp = "iss"
        case audience = "aud"
        case vpId = "jti"
        case verifiablePresentation = "vp"
        case iat, exp, nonce, nbf
    }
    
    public init(vpId: String = "",
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

public typealias VerifiablePresentation = JwsToken<VerifiablePresentationClaims>
