/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Formats a raw OpenID4VCI Request to send to credential endpoint.
 */
struct OpenID4VCIPreAuthTokenResolver
{
    private let configuration: LibraryConfiguration
    
    init(configuration: LibraryConfiguration) 
    {
        self.configuration = configuration
    }
    
    func resolve(using credentialOfferGrant: CredentialOfferGrant) async throws -> String
    {
        let url = try URL.getRequiredProperty(property: URL(string: credentialOfferGrant.authorization_server),
                                              propertyName: "authorization_server")
        
        let code = try CredentialOfferGrant.getRequiredProperty(property: credentialOfferGrant.pre_authorized_code,
                                                                propertyName: "pre-authorized_code")
        
        let request = PreAuthTokenRequest(grant_type: "urn:ietf:params:oauth:grant-type:pre-authorized_code",
                                          pre_authorized_code: code,
                                          tx_code: nil)
        
        let response = try await configuration.networking.post(requestBody: request,
                                                               url: url,
                                                               OpenID4VCIPreAuthTokenPostOperation.self,
                                                               additionalHeaders: nil)
        
        let accessToken = try PreAuthTokenResponse.getRequiredProperty(property: response.access_token,
                                                                       propertyName: "access_token")
        
        return accessToken
    }
}
