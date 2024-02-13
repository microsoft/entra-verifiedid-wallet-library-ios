/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Handles a Raw Request expected to be a Credential Offer and configures a VerifiedIdRequest object.
 */
struct OpenId4VCIHandler: RequestProcessing
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
        let credentialMetadata = try await fetchCredentialMetadata(url: credentialOffer.credential_issuer)
        
        try credentialMetadata.validateAuthorizationServers(credentialOffer: credentialOffer)
        
        // Validate signed metadata and get Root of Trust.
        let _ = try await validateSignedMetadataAndGetRootOfTrust(credentialMetadata: credentialMetadata)
        
        // TODO: transform payload into VerifiedIdRequest
        throw OpenId4VCIValidationError.MalformedCredentialMetadata(message: "Not implemented yet.")
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
}
