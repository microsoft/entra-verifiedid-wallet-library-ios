/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Formats a raw OpenID4VCI Request to send to credential endpoint.
 */
struct RawOpenID4VCIRequestFormatter
{
    /// Formats the headers for the token.
    private let headerFormatter = JwsHeaderFormatter()
    
    /// Configuration settings for the library
    private let configuration: LibraryConfiguration
    
    init(configuration: LibraryConfiguration)
    {
        self.configuration = configuration
    }
    
    /// Format the `RawOpenID4VCIRequest` from the input.
    /// - Parameters:
    ///   - CredentialOffer: The Credential Offer that initiated the request.
    ///   - CredentialEndpoint: The URL that will be used to end raw request to.
    ///   - AccessToken: The access token used for authorization.
    func format(credentialOffer: CredentialOffer,
                credentialEndpoint: String,
                accessToken: String) throws -> RawOpenID4VCIRequest
    {
        guard let configurationId = credentialOffer.credential_configuration_ids.first else
        {
            let errorMessage = "Configuration Id not present in Credential Offer."
            throw OpenId4VCIValidationError.OpenID4VCIRequestCreationError(message: errorMessage)
        }
        
        let jwtProof = try formatProof(configurationId: configurationId,
                                       credentialEndpoint: credentialEndpoint,
                                       accessToken: accessToken)
        let proof = OpenID4VCIJWTProof(jwt: jwtProof)
        let rawRequest = RawOpenID4VCIRequest(credential_configuration_id: configurationId,
                                              issuer_session: credentialOffer.issuer_session,
                                              proof: proof)
        return rawRequest
    }
    
    private func formatProof(configurationId: String,
                             credentialEndpoint: String,
                             accessToken: String) throws -> String
    {
        let holderIdentifier = try configuration.identifierFactory.getIdentifier()

        let accessTokenHash = try hash(accessToken: accessToken)
        
        let claims = OpenID4VCIJWTProofClaims(credentialEndpoint: credentialEndpoint,
                                              did: holderIdentifier.id,
                                              accessTokenHash: accessTokenHash)
        
        let headers = headerFormatter.formatHeaders(identifier: holderIdentifier,
                                                    type: "openid4vci-proof+jwt")
        
        let serializedToken = try createSerializedToken(headers: headers,
                                                        claims: claims,
                                                        identifier: holderIdentifier)
        return serializedToken
    }
    
    private func hash(accessToken: String) throws -> String
    {
        guard let encodedAccessToken = accessToken.data(using: .ascii) else
        {
            let errorMessage = "Unable to hash access token."
            throw OpenId4VCIValidationError.OpenID4VCIRequestCreationError(message: errorMessage)
        }

        let hashedAccessToken = Sha256().hash(data: encodedAccessToken).prefix(16)
        return hashedAccessToken.base64URLEncodedString()
    }
    
    private func createSerializedToken(headers: Header,
                                       claims: OpenID4VCIJWTProofClaims,
                                       identifier: HolderIdentifier) throws -> String
    {
        guard var jwt = JwsToken(headers: headers, content: claims) else
        {
            let errorMessage = "Unable to create Proof JWT."
            throw OpenId4VCIValidationError.OpenID4VCIRequestCreationError(message: errorMessage)
        }
        
        do
        {
            try jwt.sign(using: identifier)
            return try jwt.serialize()
        }
        catch
        {
            let errorMessage = "Unable to format the Proof Token."
            throw OpenId4VCIValidationError.OpenID4VCIRequestCreationError(message: errorMessage,
                                                                           error: error)
        }
    }
}
