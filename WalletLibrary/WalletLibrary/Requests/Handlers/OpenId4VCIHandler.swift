/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum OpenId4VCIHandlerError: Error
{
    case Unimplemented
    case InputNotSupported
}

/**
 * Handles a raw Open Id request and configures a VeriifedIdRequest object.
 * Post Private Preview TODO: add processors to support multiple profiles of open id.
 */
struct OpenId4VCIHandler: RequestHandling
{
    private let configuration: LibraryConfiguration
    
    init(configuration: LibraryConfiguration) 
    {
        self.configuration = configuration
    }
    
    func canHandle(rawRequest: Any) -> Bool
    {
        guard let request = rawRequest as? [String: Any],
              request["credential_issuer"] != nil else
        {
            return false
        }
        
        return true
    }
    
    func handle(rawRequest: Any) async throws -> any VerifiedIdRequest
    {
        guard let requestJson = rawRequest as? [String: Any] else
        {
            throw OpenId4VCIHandlerError.InputNotSupported
        }
        
        // TODO: validate payloads.
        let credentialOffer = try configuration.mapper.map(requestJson, type: CredentialOffer.self)
        let credentialMetadata = try await fetchCredentialMetadata(url: credentialOffer.credential_issuer)
        
        throw OpenId4VCIHandlerError.Unimplemented
    }
    
    private func fetchCredentialMetadata(url: String) async throws -> CredentialMetadata
    {
        guard let url = URL(string: url) else
        {
            throw OpenId4VCIHandlerError.InputNotSupported
        }
        
        return try await configuration.networking.fetch(url: url, CredentialMetadataFetchOperation.self)
    }
}
