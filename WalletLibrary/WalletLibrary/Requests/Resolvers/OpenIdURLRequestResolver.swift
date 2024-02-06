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
    case URLDoesNotContainProperQueryItem(url: String)
    case Unimplemented
}

/**
 * Resolves a raw Open Id request from a URL input.
 */
struct OpenIdURLRequestResolver: RequestResolving 
{
    
    struct Constants
    {
        static let OpenIdScheme = "openid-vc"
        static let RequestURI = "request_uri"
        static let CredentialOfferURI = "credential_offer_uri"
    }
    
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
        
        if input.url.scheme == Constants.OpenIdScheme
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
        
        /// If preview features are not supported, fallback to VC SDK implementation.
        return try await openIdResolver.getRequest(url: input.url.absoluteString)
    }
    
    private func resolveUsingOpenID4VCI(input: VerifiedIdRequestURL) async throws -> Any
    {
        
        guard let requestUri = getRequestUri(openIdURL: input.url) else
        {
            throw OpenIdURLRequestResolverError.URLDoesNotContainProperQueryItem(url: input.url.absoluteString)
        }
        
        /// Fetch a serialized request that could be OpenID Request or Credential Offer.
        let serializedRequest: Data = try await configuration.networking.fetch(url: requestUri,
                                                                               OpenID4VCIRequestNetworkOperation.self)
        do
        {
            /// If request is JSON, serialize the request.
            let rawRequest = try JSONSerialization.jsonObject(with: serializedRequest)
            return rawRequest
        }
        catch
        {
            /// If unable to parse JSON, fallback to VC SDK implementation.
            let presentationRequest = try await openIdResolver.validateRequest(data: serializedRequest)
            return presentationRequest
        }
    }
    
    private func getRequestUri(openIdURL: URL) -> URL? 
    {
        guard let urlComponents = URLComponents(url: openIdURL, resolvingAgainstBaseURL: true),
              let queryItems = urlComponents.percentEncodedQueryItems else
        {
            return nil
        }
        
        for queryItem in queryItems 
        {
            if (queryItem.name == Constants.RequestURI || queryItem.name == Constants.CredentialOfferURI),
               let value = queryItem.value?.removingPercentEncoding
            {
                return URL(unsafeString: value)
            }
        }
        
        return nil
    }
}
