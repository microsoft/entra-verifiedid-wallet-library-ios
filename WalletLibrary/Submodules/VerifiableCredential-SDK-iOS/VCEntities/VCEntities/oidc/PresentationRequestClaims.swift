/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

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
    
    let iat: Int?
    
    let exp: Int?
    
    let pin: PinDescriptor?
    
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case redirectURI = "redirect_uri"
        case responseType = "response_type"
        case responseMode = "response_mode"
        case idTokenHint = "id_token_hint"
        case state, nonce, prompt, registration, iat, exp, scope, claims, jti, pin
    }
    
    init(jti: String? = nil,
         clientID: String? = nil,
         redirectURI: String? = nil,
         responseMode: String? = nil,
         responseType: String? = nil,
         claims: RequestedClaims?,
         state: String? = nil,
         nonce: String? = nil,
         scope: String? = nil,
         prompt: String? = nil,
         registration: RegistrationClaims? = nil,
         idTokenHint: String? = nil,
         iat: Int? = nil,
         exp: Int? = nil,
         pin: PinDescriptor? = nil) {
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
