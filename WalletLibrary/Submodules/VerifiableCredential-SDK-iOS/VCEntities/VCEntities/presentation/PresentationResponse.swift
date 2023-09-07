/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum PresentationResponseDecodingError: Error {
    case unableToDecodeIdToken
    case unableToDecodeVpToken
}

struct PresentationResponse: Codable {
    
    let idToken: PresentationResponseToken
    
    let vpTokens: [VerifiablePresentation]
    
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
        case vpTokens = "vp_token"
        case state
    }
    
    init(idToken: PresentationResponseToken,
         vpTokens: [VerifiablePresentation],
         state: String?) {
        self.idToken = idToken
        self.vpTokens = vpTokens
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
        
        if let vpTokensSerialized = try values.decodeIfPresent([String].self, forKey: .vpTokens) {
            self.vpTokens = try vpTokensSerialized.map {
                if let vp = VerifiablePresentation(from: $0) {
                    return vp
             } else {
                 throw PresentationResponseDecodingError.unableToDecodeVpToken
             }
                
            }
        } else {
            throw PresentationResponseDecodingError.unableToDecodeVpToken
        }
        state = try values.decodeIfPresent(String.self, forKey: .state)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let jwsEncoder = JwsEncoder()
        try container.encodeIfPresent(jwsEncoder.encode(idToken), forKey: .idToken)
        let serializedVpTokens = try vpTokens.map { try jwsEncoder.encode($0) }
        try container.encodeIfPresent(serializedVpTokens, forKey: .vpTokens)
        try container.encodeIfPresent(state, forKey: .state)
    }
}
