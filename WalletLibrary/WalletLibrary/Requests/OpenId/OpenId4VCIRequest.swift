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
    
    /// The credential configuration that describes the credential from credential metadata.
    private let credentialConfiguration: CredentialConfiguration
    
    /// The formatter to handle formatting request to a`RawOpenID4VCIRequest`.
    private let requestFormatter: RawOpenID4VCIRequestFormatter
    
    /// The library configuration.
    private let configuration: LibraryConfiguration
    
    init(style: RequesterStyle,
         verifiedIdStyle: VerifiedIdStyle,
         rootOfTrust: RootOfTrust,
         requirement: Requirement,
         credentialMetadata: CredentialMetadata,
         credentialConfiguration: CredentialConfiguration,
         credentialOffer: CredentialOffer,
         configuration: LibraryConfiguration)
    {
        self.style = style
        self.verifiedIdStyle = verifiedIdStyle
        self.rootOfTrust = rootOfTrust
        self.requirement = requirement
        self.credentialMetadata = credentialMetadata
        self.credentialConfiguration = credentialConfiguration
        self.credentialOffer = credentialOffer
        self.configuration = configuration
        self.requestFormatter = RawOpenID4VCIRequestFormatter(configuration: configuration)
    }
    
    /// Completes the issuance process, returning the result of the issuance request.
    /// - Returns: A `VerifiedIdResult` containing the issued `VerifiedId` or an `VerifiedIdError`.
    public func complete() async -> VerifiedIdResult<VerifiedId>
    {
        let result = await VerifiedIdResult<VerifiedId>.getResult {
            let response = try await self.sendIssuanceRequest()
            return try self.mapToVerifiedId(rawResponse: response)
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
    
    private func sendIssuanceRequest() async throws -> RawOpenID4VCIResponse
    {
        guard let accessTokenRequirement = requirement as? AccessTokenRequirement,
              let accessToken = accessTokenRequirement.accessToken else
        {
            let errorMessage = "Access token not defined on requirement."
            throw OpenId4VCIValidationError.OpenID4VCIRequestCreationError(message: errorMessage)
        }
        
        guard let credentialEndpoint = credentialMetadata.credential_endpoint,
              let endpointURL = URL(string: credentialEndpoint) else
        {
            let errorMessage = "Credential Endpoint not set on Credential Metadata."
            throw OpenId4VCIValidationError.MalformedCredentialMetadata(message: errorMessage)
        }
        
        let rawRequest = try createRawRequest(accessToken: accessToken,
                                              credentialEndpoint: credentialEndpoint)
        let authorizationHeader = ["Authorization": "Bearer \(accessToken)"]
        
        let response = try await configuration.networking.post(requestBody: rawRequest,
                                                               url: endpointURL,
                                                               OpenID4VCIPostOperation.self,
                                                               additionalHeaders: authorizationHeader)
        return response
    }
    
    private func createRawRequest(accessToken: String,
                                  credentialEndpoint: String) throws -> RawOpenID4VCIRequest
    {
        let rawRequest = try requestFormatter.format(credentialOffer: credentialOffer,
                                                     credentialEndpoint: credentialEndpoint,
                                                     accessToken: accessToken)
        return rawRequest
    }
    
    private func mapToVerifiedId(rawResponse: RawOpenID4VCIResponse) throws -> VerifiedId
    {
        let credential = try RawOpenID4VCIResponse.getRequiredProperty(property: rawResponse.credential,
                                                                       propertyName: "credential")
        
        let issuerName = credentialMetadata.getPreferredLocalizedIssuerDisplayDefinition().name
        
        let verifiedId = try OpenID4VCIVerifiedId(raw: credential,
                                                  issuerName: issuerName,
                                                  configuration: credentialConfiguration)
        return verifiedId
    }
}
