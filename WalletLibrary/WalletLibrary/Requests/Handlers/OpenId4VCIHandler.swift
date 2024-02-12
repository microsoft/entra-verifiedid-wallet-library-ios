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
    
    private let signedMetadataProcessor: SignedCredentialMetadataProcessor
    
    init(configuration: LibraryConfiguration,
         signedMetadataProcessor: SignedCredentialMetadataProcessor? = nil)
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
    /// TODO: finish implementation in next PR.
    func handle(rawRequest: Any) async throws -> any VerifiedIdRequest
    {
        guard let requestJson = rawRequest as? [String: Any] else
        {
            let errorMessage = "Request is not in the correct format."
            throw OpenId4VCIValidationError.MalformedCredentialOffer(message: errorMessage)
        }
        
        let credentialOffer = try configuration.mapper.map(requestJson, type: CredentialOffer.self)
        let metadata = try await fetchCredentialMetadata(url: credentialOffer.credential_issuer)
        
        
        try metadata.validateAuthorizationServers(credentialOffer: credentialOffer)
        
        // Validate signed metadata and get Root of Trust.
        let rootOfTrust = try await validateSignedMetadataAndGetRootOfTrust(credentialMetadata: metadata)
        
        guard let config = metadata.getCredentialConfigurations(ids: credentialOffer.credential_configuration_ids).first else
        {
            let errorMessage = "Request does not contain expected credential configuration."
            throw OpenId4VCIValidationError.MalformedCredentialOffer(message: errorMessage)
        }
        
        let requesterStyle = getRequesterStyle(metadata: metadata)
        let verifiedIdStyle = getVerifiedIdStyle(metadata: metadata,
                                                 credentialConfigIds: credentialOffer.credential_configuration_ids,
                                                 issuerName: requesterStyle.name)
        
        let requirement = try getRequirement(scope: config.scope, credentialOffer: credentialOffer)
        
        return OpenId4VCIRequest(style: requesterStyle,
                                 verifiedIdStyle: verifiedIdStyle,
                                 rootOfTrust: rootOfTrust,
                                 requirement: requirement,
                                 credentialMetadata: metadata,
                                 credentialOffer: credentialOffer,
                                 configuration: configuration)
    }
    
    private func fetchCredentialMetadata(url: String) async throws -> CredentialMetadata
     {
         let url = try URL.getRequiredProperty(property: URL(string: url), propertyName: "credential_issuer")
         return try await configuration.networking.fetch(url: url, CredentialMetadataFetchOperation.self)
     }
     
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
    
    // Only supports Access Token Requirement.
    private func getRequirement(scope: String?, credentialOffer: CredentialOffer) throws -> Requirement
    {
        guard let grant = credentialOffer.grants["authorization_code"] else
        {
            let errorMessage = "Request is not in the correct format."
            throw OpenId4VCIValidationError.MalformedCredentialOffer(message: errorMessage)
        }
        
        guard let scope = scope else
        {
            let errorMessage = "Request is not in the correct format."
            throw OpenId4VCIValidationError.MalformedCredentialOffer(message: errorMessage)
        }
        
        return AccessTokenRequirement(configuration: grant.authorization_server,
                                      resourceId: "", // resource id is not needed.
                                      scope: scope)
    }
    
    private func getRequesterStyle(metadata: CredentialMetadata) -> RequesterStyle
    {
        let issuerName = metadata.display.first?.name
        let issuerStyle = VerifiedIdManifestIssuerStyle(name: issuerName ?? "")
        return issuerStyle
    }
    
    private func getVerifiedIdStyle(metadata: CredentialMetadata,
                                    credentialConfigIds: [String],
                                    issuerName: String) -> VerifiedIdStyle
    {
        // Only support one right now.
        let config = metadata.getCredentialConfigurations(ids: credentialConfigIds).first
        let definition = config?.credential_definition?.display?.first
        let logo = definition?.logo.flatMap { try? configuration.mapper.map($0) }
        
        let style = BasicVerifiedIdStyle(name: definition?.name ?? "",
                                         issuer: issuerName,
                                         backgroundColor: definition?.background_color ?? "",
                                         textColor: definition?.text_color ?? "",
                                         description: "",
                                         logo: logo)
        
        return style
    }
}
