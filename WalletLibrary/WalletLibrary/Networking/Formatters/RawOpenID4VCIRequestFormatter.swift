/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct RawOpenID4VCIRequestFormatter
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
