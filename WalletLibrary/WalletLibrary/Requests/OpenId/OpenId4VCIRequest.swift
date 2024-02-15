/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The `OpenId4VCIRequest` class is designed to handle issuance requests in compliance with
 * the OpenId4VCI Protocol.
 *
 * The class extends the functionality of`VerifiedIdIssuanceRequest`.
 */
class OpenId4VCIRequest: VerifiedIdIssuanceRequest
{
    /// The look and feel of the requester.
    public let style: RequesterStyle
    
    /// The look and feel of the verified id.
    public let verifiedIdStyle: VerifiedIdStyle
    
    /// The requirement needed to fulfill request.
    public let requirement: Requirement
    
    /// The root of trust results between the request and the source of the request.
    public let rootOfTrust: RootOfTrust
    
    /// The metadata about the credential being requested.
    private let credentialMetadata: CredentialMetadata
    
    /// The credential offer for the credential being requested.
    private let credentialOffer: CredentialOffer
    
    private let requestFormatter: OpenId4VCIRequestFormatter
    
    /// The library configuration.
    private let configuration: LibraryConfiguration
    
    init(style: RequesterStyle,
         verifiedIdStyle: VerifiedIdStyle,
         rootOfTrust: RootOfTrust,
         requirement: Requirement,
         credentialMetadata: CredentialMetadata,
         credentialOffer: CredentialOffer,
         configuration: LibraryConfiguration)
    {
        self.style = style
        self.verifiedIdStyle = verifiedIdStyle
        self.rootOfTrust = rootOfTrust
        self.requirement = requirement
        self.credentialMetadata = credentialMetadata
        self.credentialOffer = credentialOffer
        self.configuration = configuration
        self.requestFormatter = OpenId4VCIRequestFormatter(configuration: configuration)
    }
    
    /// Completes the issuance process, returning the result of the issuance request.
    /// - Returns: A `VerifiedIdResult` containing the issued `VerifiedId` or an `VerifiedIdError`.
    public func complete() async -> VerifiedIdResult<VerifiedId>
    {
        let result = await VerifiedIdResult<VerifiedId>.getResult {
            return try await self.sendIssuanceRequest()
        }
        
        return result
    }
    

    /// Cancels the issuance request, potentially with a custom message describing the reason for cancellation.
    public func cancel(message: String?) async -> VerifiedIdResult<Void>
    {
        let result = await VerifiedIdResult<VerifiedId>.getResult {
            let errorMessage = "Not implemented."
            throw VerifiedIdError(message: errorMessage, code: "")
        }
        
        return result
    }
    
    private func sendIssuanceRequest() async throws -> VerifiedId
    {
        let rawRequest = try createRawRequest()
        
        guard let accessTokenRequirement = requirement as? AccessTokenRequirement,
              let accessToken = accessTokenRequirement.accessToken else
        {
            throw OpenId4VCIValidationError.MalformedCredentialMetadata(message: "")
        }
        
        let url = URL(string: credentialMetadata.credential_endpoint!)!
        let test = try await configuration.networking.post(requestBody: rawRequest,
                                                           url: url,
                                                           OpenID4VCIPostOperation.self,
                                                           additionalHeaders: ["Authorization": "Bearer \(accessToken)"])
        
        let credential = try RawOpenID4VCIResponse.getRequiredProperty(property: test.credential,
                                                                       propertyName: "credential")
        
        let config = credentialMetadata.getCredentialConfigurations(ids: credentialOffer.credential_configuration_ids).first!
        let issuerName = credentialMetadata.getPreferredLocalizedIssuerDisplayDefinition().name
        
        let verifiedId = try OpenID4VCIVerifiedId(raw: credential,
                                                  issuerName: issuerName,
                                                  configuration: config)
        return verifiedId
    }
    
    private func createRawRequest() throws -> RawOpenID4VCIRequest
    {
        guard let accessTokenRequirement = requirement as? AccessTokenRequirement,
              let accessToken = accessTokenRequirement.accessToken else
        {
            throw OpenId4VCIValidationError.MalformedCredentialMetadata(message: "")
        }
        
        let rawRequest = try requestFormatter.format(credentialOffer: credentialOffer,
                                                     credentialEndpoint: credentialMetadata.credential_endpoint!,
                                                     accessToken: accessToken)
        return rawRequest
    }
}

struct OpenId4VCIRequestFormatter
{
    private let signer: TokenSigning
    
    private let headerFormatter = JwsHeaderFormatter()
    
    private let configuration: LibraryConfiguration
    
    init(signer: TokenSigning = Secp256k1Signer(),
         configuration: LibraryConfiguration)
    {
        self.signer = signer
        self.configuration = configuration
    }
    
    func format(credentialOffer: CredentialOffer,
                credentialEndpoint: String,
                accessToken: String) throws -> RawOpenID4VCIRequest
    {
        guard let configurationId = credentialOffer.credential_configuration_ids.first else
        {
            throw OpenId4VCIValidationError.MalformedCredentialMetadata(message: "")
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
            throw FormatterError.noSigningKeyFound
        }
        
//        guard let accessToken = Data(base64URLEncoded: accessToken) else
//        {
//            throw OpenId4VCIValidationError.MalformedCredentialMetadata(message: "")
//        }
//        
//        let hashedAccessToken = Sha256().hash(data: accessToken).base64URLEncodedString()
        
        let claims = OpenID4VCIJWTProofClaims(credentialEndpoint: credentialEndpoint,
                                              did: identifier.longFormDid,
                                              accessTokenHash: accessToken)
        
        let headers = headerFormatter.formatHeaders(usingIdentifier: identifier,
                                                    andSigningKey: signingKey,
                                                    type: "openid4vci-proof+jwt")
        
        guard var jwt = JwsToken(headers: headers, content: claims) else
        {
            throw OpenId4VCIValidationError.MalformedCredentialMetadata(message: "")
        }
        
        try jwt.sign(using: signer, withSecret: signingKey.keyReference)
        
        // sign JWT
        return try jwt.serialize()
    }
}
