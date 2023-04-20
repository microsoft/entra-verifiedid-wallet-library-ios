/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

/// OIDC Claims that represent a Verifiable Credential Presentation Request.
public struct PresentationRequestClaims: OIDCClaims, Equatable {
    
    public let jti: String?
    
    public let clientID: String?
    
    public let redirectURI: String?
    
    public let responseType: String?
    
    public let responseMode: String?
    
    public let claims: RequestedClaims?
    
    public let state: String?
    
    public let nonce: String?
    
    public let scope: String?
    
    /// flag to determine if presentation request can go into issuance flow
    public let prompt: String?
    
    public let registration: RegistrationClaims?
    
    public let idTokenHint: String?
    
    public let iat: Double?
    
    public let exp: Double?
    
    public let pin: PinDescriptor?
    
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case redirectURI = "redirect_uri"
        case responseType = "response_type"
        case responseMode = "response_mode"
        case idTokenHint = "id_token_hint"
        case state, nonce, prompt, registration, iat, exp, scope, claims, jti, pin
    }
    
    public init(jti: String?,
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
public typealias PresentationRequestToken = JwsToken<PresentationRequestClaims>
