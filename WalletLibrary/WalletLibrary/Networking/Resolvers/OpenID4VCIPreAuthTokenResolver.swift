/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Formats a raw OpenID4VCI Request to send to credential endpoint.
 */
struct OpenID4VCIPreAuthTokenResolver
{
    
    private struct Constants
    {
        static let GrantType = "urn:ietf:params:oauth:grant-type:pre-authorized_code"
    }
    
    private let configuration: LibraryConfiguration
    
    init(configuration: LibraryConfiguration) 
    {
        self.configuration = configuration
    }
    
    func resolve(using credentialOfferGrant: CredentialOfferGrant,
                 pin: String? = nil) async throws -> String
    {
        let code = try CredentialOfferGrant.getRequiredProperty(property: credentialOfferGrant.pre_authorized_code,
                                                                propertyName: "pre-authorized_code")
        
        let tokenEndpoint = try await getTokenEndpoint(authorizationServer: credentialOfferGrant.authorization_server)
        
        let request = PreAuthTokenRequest(grant_type: Constants.GrantType,
                                          pre_authorized_code: code,
                                          tx_code: pin)
        
        let response = try await configuration.networking.post(requestBody: request,
                                                               url: tokenEndpoint,
                                                               OpenID4VCIPreAuthTokenPostOperation.self,
                                                               additionalHeaders: nil)
        
        let accessToken = try PreAuthTokenResponse.getRequiredProperty(property: response.access_token,
                                                                       propertyName: "access_token")
        
        return accessToken
    }
    
    private func getTokenEndpoint(authorizationServer: String) async throws -> URL
    {
        let authorizationServerURL = try URL.getRequiredProperty(property: URL(string: authorizationServer),
                                                                 propertyName: "authorization_server")
        
        let wellKnownConfiguration = try await configuration.networking.fetch(url: authorizationServerURL,
                                                                              OpenIDWellKnownConfigFetchOperation.self)
        
        guard let grantTypesSupportedInWellKnownConfig = wellKnownConfiguration.grant_types_supported,
              grantTypesSupportedInWellKnownConfig.contains(Constants.GrantType) else
        {
            throw OpenId4VCIValidationError.PreAuthError(message: "Grant type not included in well-known configuration.")
        }
        
        guard let tokenEndpoint = wellKnownConfiguration.token_endpoint,
              let tokenEndpointURL = URL(string: tokenEndpoint) else
        {
            throw OpenId4VCIValidationError.PreAuthError(message: "Missing token endpoint in well-known configuration.")
        }
        
        // RFC 8414 §3.3: the `issuer` returned in the authorization server metadata MUST be identical
        // to the authorization server identifier used to fetch it. Enforcing this prevents a malicious
        // host from serving metadata that impersonates a legitimate authorization server.
        guard let wellKnownIssuer = wellKnownConfiguration.issuer,
              URL.haveSameIdentifier(wellKnownIssuer, authorizationServer) else
        {
            throw OpenId4VCIValidationError.PreAuthError(message: "Well-known configuration issuer does not match the requested authorization server.")
        }
        
        return tokenEndpointURL
    }
}
