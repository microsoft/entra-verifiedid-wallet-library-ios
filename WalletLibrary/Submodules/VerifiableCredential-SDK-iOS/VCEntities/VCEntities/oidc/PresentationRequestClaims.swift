/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

/// OIDC Claims that represent a Verifiable Credential Presentation Request.
struct PresentationRequestClaims: OIDCClaims, Equatable {
    
    let jti: String?
    
    let clientID: String?
    
    let redirectURI: String?
    
    let responseType: String?
    
    let responseMode: String?
    
    let claims: RequestedClaims?
    
    let state: String?
    
    let nonce: String?
    
    let scope: String?
    
    /// flag to determine if presentation request can go into issuance flow
    let prompt: String?
    
    let registration: RegistrationClaims?
    
    let idTokenHint: String?
    
    let iat: Double?
    
    let exp: Double?
    
    let pin: PinDescriptor?
    
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case redirectURI = "redirect_uri"
        case responseType = "response_type"
        case responseMode = "response_mode"
        case idTokenHint = "id_token_hint"
        case state, nonce, prompt, registration, iat, exp, scope, claims, jti, pin
    }
    
    init(jti: String?,
                clientID: String?,
                redirectURI: String?,
                responseMode: String?,
                responseType: String?,
                claims: RequestedClaims?,
                state: String?,
                nonce: String?,
                scope: String?,
                prompt: String?,
                registration: RegistrationClaims?,
                idTokenHint: String? = nil,
                iat: Double?,
                exp: Double?,
                pin: PinDescriptor?) {
        self.jti = jti
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.responseType = responseType
        self.responseMode = responseMode
        self.claims = claims
        self.state = state
        self.nonce = nonce
        self.scope = scope
        self.prompt = prompt
        self.registration = registration
        self.idTokenHint = idTokenHint
        self.iat = iat
        self.exp = exp
        self.pin = pin
    }
}

/// JWT representation of a Presentation Request.
typealias PresentationRequestToken = JwsToken<PresentationRequestClaims>