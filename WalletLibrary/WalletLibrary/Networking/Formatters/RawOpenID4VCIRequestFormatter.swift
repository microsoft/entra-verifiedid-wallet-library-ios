/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Formats a raw OpenID4VCI Request to send to credential endpoint.
 */
struct RawOpenID4VCIRequestFormatter
{
    /// Used to sign the proof token.
    private let signer: TokenSigning
    
    /// Formats the headers for the token.
    private let headerFormatter = JwsHeaderFormatter()
    
    /// Configuration settings for the library
    private let configuration: LibraryConfiguration
    
    init(signer: TokenSigning = Secp256k1Signer(),
         configuration: LibraryConfiguration)
    {
        self.signer = signer
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
        guard let identifier = try? configuration.identifierManager.fetchOrCreateMasterIdentifier(),
              let signingKey = identifier.didDocumentKeys.first else
        {
            let errorMessage = "Unable to fetch user's signing key reference."
            throw OpenId4VCIValidationError.OpenID4VCIRequestCreationError(message: errorMessage)
        }

        let accessTokenHash = try hash(accessToken: accessToken)
        
        let claims = OpenID4VCIJWTProofClaims(credentialEndpoint: credentialEndpoint,
                                              did: identifier.longFormDid,
                                              accessTokenHash: accessTokenHash)
        
        let headers = headerFormatter.formatHeaders(usingIdentifier: identifier,
                                                    andSigningKey: signingKey,
                                                    type: "openid4vci-proof+jwt")
        
        let serializedToken = try creatSerializedToken(headers: headers,
                                                       claims: claims,
                                                       keyReference: signingKey.keyReference)
        return serializedToken
    }
    
    private func hash(accessToken: String) throws -> String
    {
        guard let encodedAccessToken = accessToken.data(using: .utf8) else
        {
            let errorMessage = "Unable to hash access token."
            throw OpenId4VCIValidationError.OpenID4VCIRequestCreationError(message: errorMessage)
        }

        let hashedAccessToken = Sha256().hash(data: encodedAccessToken).base64URLEncodedString()
        return hashedAccessToken
    }
    
    private func createSerializedToken(headers: Header,
                                      claims: OpenID4VCIJWTProofClaims,
                                      keyReference: VCCryptoSecret) throws -> String
    {
        guard var jwt = JwsToken(headers: headers, content: claims) else
        {
            let errorMessage = "Unable to create Proof JWT."
            throw OpenId4VCIValidationError.OpenID4VCIRequestCreationError(message: errorMessage)
        }
        
        do
        {
            try jwt.sign(using: signer, withSecret: keyReference)
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
