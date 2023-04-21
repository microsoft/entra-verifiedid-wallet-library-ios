/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

enum PresentationResponseDecodingError: Error {
    case unableToDecodeIdToken
    case unableToDecodeVpToken
}

struct PresentationResponse: Codable {
    
    let idToken: PresentationResponseToken
    
    let vpToken: VerifiablePresentation?
    
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
        case vpToken = "vp_token"
        case state
    }
    
    init(idToken: PresentationResponseToken,
                vpToken: VerifiablePresentation?,
                state: String?) {
        self.idToken = idToken
        self.vpToken = vpToken
        self.state = state
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let idTokenSerialized = try values.decodeIfPresent(String.self, forKey: .idToken),
           let token = JwsToken<PresentationResponseClaims>(from: idTokenSerialized) {
            idToken = token
        } else {
            throw PresentationResponseDecodingError.unableToDecodeIdToken
        }
        if let vpTokenSerialized = try values.decodeIfPresent(String.self, forKey: .vpToken),
           let vp = VerifiablePresentation(from: vpTokenSerialized) {
               vpToken = vp
        } else {
            throw PresentationResponseDecodingError.unableToDecodeVpToken
        }
        state = try values.decodeIfPresent(String.self, forKey: .state)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let jwsEncoder = JwsEncoder()
        try container.encodeIfPresent(jwsEncoder.encode(idToken), forKey: .idToken)
        if let vpToken = vpToken {
            try container.encodeIfPresent(jwsEncoder.encode(vpToken), forKey: .vpToken)
        }
        try container.encodeIfPresent(state, forKey: .state)
    }
}
