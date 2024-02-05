/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Errors associated with the Open Id URL Request Resolver.
 */
enum OpenIdURLRequestResolverError: Error 
{
    case UnsupportedVerifiedIdRequestInputWith(type: String)
    case Unimplemented
}

/**
 * Resolves a raw Open Id request from a URL input.
 */
struct OpenIdURLRequestResolver: RequestResolving 
{
    
    private let openIdScheme = "openid-vc"
    
    private let openIdResolver: OpenIdForVCResolver
    
    private let configuration: LibraryConfiguration
    
    init(openIdResolver: OpenIdForVCResolver, configuration: LibraryConfiguration) 
    {
        self.openIdResolver = openIdResolver
        self.configuration = configuration
    }
    
    /// Whether or not the resolver can resolve input given.
    func canResolve(input: VerifiedIdRequestInput) -> Bool 
    {
        guard let input = input as? VerifiedIdRequestURL else
        {
            return false
        }
        
        if input.url.scheme == openIdScheme 
        {
            return true
        }
        
        return false
    }
    
    /// Resolve raw request from input given.
    func resolve(input: VerifiedIdRequestInput) async throws -> Any 
    {
        guard let input = input as? VerifiedIdRequestURL else 
        {
            throw OpenIdURLRequestResolverError.UnsupportedVerifiedIdRequestInputWith(type: String(describing: type(of: input)))
        }
        
        // TODO: split access token and pre-auth token flows up.
        if configuration.isPreviewFeatureFlagSupported(PreviewFeatureFlags.OpenID4VCIAccessToken)
        {
            return try await resolveUsingOpenID4VCI(input: input)
        }
        
        // TODO: add support for Credential Offer and fall back to old Issuance flow.
        return try await openIdResolver.getRequest(url: input.url.absoluteString)
    }
    
    // TODO: Implement for OpenID4VCI Flow.
    private func resolveUsingOpenID4VCI(input: VerifiedIdRequestURL) async throws -> Any
    {
        let serializedRequest = try await configuration.networking.fetch(url: input.url,
                                                                         OpenID4VCIRequestNetworkOperation.self)
        throw OpenIdURLRequestResolverError.Unimplemented
    }
}
