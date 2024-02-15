/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Handles a Raw Request expected to be a Credential Offer and configures a VerifiedIdRequest object.
 */
struct OpenId4VCIHandler: RequestHandling
{
    private let configuration: LibraryConfiguration
    
    private let signedMetadataProcessor: SignedCredentialMetadataProcessing
    
    init(configuration: LibraryConfiguration,
         signedMetadataProcessor: SignedCredentialMetadataProcessing? = nil)
    {
        self.configuration = configuration
        self.signedMetadataProcessor = signedMetadataProcessor ?? SignedCredentialMetadataProcessor(configuration: configuration)
    }
    
    /// Determines whether a given raw request can be handled by this handler.
    ///
    /// This method checks if the raw request can be cast to a dictionary and contains
    /// a specific key (`credential_issuer`), indicating it is a valid request for processing.
    ///
    /// - Parameter rawRequest: The raw request to be evaluated, expected to be a dictionary.
    func canHandle(rawRequest: Any) -> Bool
    {
        guard let request = rawRequest as? [String: Any],
              let _ = try? configuration.mapper.map(request,
                                                    type: CredentialOffer.self) else
        {
            return false
        }
        
        return true
    }
    
    /// Processes a given raw request expected to be a dictionary, collects the rest of the request,
    /// validates the request, and returns a `VerifiedIdRequest` object.
    ///
    /// - Parameter rawRequest: The raw request to be processed, expected to be a dictionary.
    func handle(rawRequest: Any) async throws -> any VerifiedIdRequest
    {
        guard let requestJson = rawRequest as? [String: Any] else
        {
            let errorMessage = "Request is not in the correct format."
            throw OpenId4VCIValidationError.MalformedCredentialOffer(message: errorMessage)
        }
        
        /// Transform raw request into `CredentialOffer` and fetch `CredentialMetadata`.
        let credentialOffer = try configuration.mapper.map(requestJson, type: CredentialOffer.self)
        let credentialMetadata = try await fetchCredentialMetadata(url: credentialOffer.credential_issuer)
        
        /// Validate the `CredentialMetadata` contains credential config ids from `CredentialOffer`.
        let configIds = credentialOffer.credential_configuration_ids
        guard let credentialConfig = credentialMetadata.getCredentialConfigurations(ids: configIds).first else
        {
            let errorMessage = "Request does not contain expected credential configuration."
            throw OpenId4VCIValidationError.MalformedCredentialMetadata(message: errorMessage)
        }
        
        /// Validate properties on signed metadata and get `RootOfTrust`.
        try credentialMetadata.validateAuthorizationServers(credentialOffer: credentialOffer)
        let rootOfTrust = try await validateSignedMetadataAndGetRootOfTrust(credentialMetadata: credentialMetadata)
        
        /// Transform `CredentialMetadata` and `CredentialOffer` into public `Style` data models.
        let requesterStyle = credentialMetadata.getPreferredLocalizedIssuerDisplayDefinition()
        let verifiedIdStyle = credentialConfig.getLocalizedVerifiedIdStyle(withIssuerName: requesterStyle.name)
        
        /// Transform `CredentialMetadata` and `CredentialOffer` into Requirement.
        let requirement = try getRequirement(scope: credentialConfig.scope, credentialOffer: credentialOffer)
        
        return OpenId4VCIRequest(style: requesterStyle,
                                 verifiedIdStyle: verifiedIdStyle,
                                 rootOfTrust: rootOfTrust,
                                 requirement: requirement,
                                 credentialMetadata: credentialMetadata,
                                 credentialConfiguration: credentialConfig,
                                 credentialOffer: credentialOffer,
                                 configuration: configuration)
    }
    
    /// Fetch `CredentialMetadata` from "credential_issuer".
    private func fetchCredentialMetadata(url: String) async throws -> CredentialMetadata
    {
        let wellKnownUrl = CredentialMetadataFetchOperation.buildCredentialMetadataEndpoint(url: url)
        let url = try URL.getRequiredProperty(property: wellKnownUrl, propertyName: "credential_issuer")
        return try await configuration.networking.fetch(url: url, CredentialMetadataFetchOperation.self)
    }
    
    /// Validate the signed metadata on `CredentialMetadata` and resolve `RootOfTrust` using signed metadata processor.
    private func validateSignedMetadataAndGetRootOfTrust(credentialMetadata: CredentialMetadata) async throws -> RootOfTrust
    {
        let signedMetadata = try CredentialMetadata.getRequiredProperty(property: credentialMetadata.signed_metadata,
                                                                        propertyName: "signed_metadata")
        
        let credentialIssuer = try CredentialMetadata.getRequiredProperty(property: credentialMetadata.credential_issuer,
                                                                          propertyName: "credential_issuer")
        
        // Validate signed metadata and get Root of Trust.
        let rootOfTrust = try await signedMetadataProcessor.process(signedMetadata: signedMetadata,
                                                                    credentialIssuer: credentialIssuer)
        return rootOfTrust
    }
    
    /// Transform `CredentialOffer` and `scope` from `CredentialMetadata` to `Requirement`.
    /// note: only support Access Token Requirement.
    private func getRequirement(scope: String?, credentialOffer: CredentialOffer) throws -> Requirement
    {
        guard let grant = credentialOffer.grants["authorization_code"] else
        {
            let errorMessage = "Grants does not contain 'authorization_code' property."
            throw OpenId4VCIValidationError.MalformedCredentialOffer(message: errorMessage)
        }
        
        guard let scope = scope else
        {
            let errorMessage = "Credential Configuration does not contain scope value."
            throw OpenId4VCIValidationError.MalformedCredentialMetadata(message: errorMessage)
        }
        
        /// resource id is the String in the scope param and scope is the resource id appended with `/.default`.
        return AccessTokenRequirement(configuration: grant.authorization_server,
                                      resourceId: scope,
                                      scope: "\(scope)/.default")
    }
}
