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
class OpenIdURLRequestResolver: RequestResolving
{
    
    private struct Constants
    {
        static let OpenIdScheme = "openid-vc"
        static let RequestURI = "request_uri"
        static let CredentialOfferURI = "credential_offer_uri"
        static let InteropProfileVersion = "oid4vci-interop-profile-version=0.0.1"
        static let PreferHeaderField = "prefer"
    }
    
    var preferHeaders: [String] = []
    
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
        
        let additionalHeaders = AdditionalHeaders()
        
        var isFeatureFlagOn = false
        
        if configuration.isPreviewFeatureFlagSupported(PreviewFeatureFlags.OpenID4VCIAccessToken) ||
            configuration.isPreviewFeatureFlagSupported(PreviewFeatureFlags.OpenID4VCIPreAuth)
        {
            additionalHeaders.addHeader(fieldName: Constants.PreferHeaderField,
                                        value: Constants.InteropProfileVersion)
            isFeatureFlagOn = true
        }
        
        if configuration.isPreviewFeatureFlagSupported(PreviewFeatureFlags.ProcessorExtensionSupport)
        {
            for header in preferHeaders 
            {
                additionalHeaders.addHeader(fieldName: Constants.PreferHeaderField,
                                            value: header)
            }
            isFeatureFlagOn = true
        }
        
        if isFeatureFlagOn
        {
            return try await resolveUsingOpenID4VCI(input: input,
                                                    additionalHeaders: additionalHeaders)
        }
        else
        {
            /// If preview features are not supported, fallback to VC SDK implementation.
            return try await openIdResolver.getRequest(url: input.url.absoluteString)
        }
    }
    
    private func resolveUsingOpenID4VCI(input: VerifiedIdRequestURL,
                                        additionalHeaders: AdditionalHeaders) async throws -> Any
    {
        guard let requestUri = getRequestUri(openIdURL: input.url) else
        {
            throw OpenIdURLRequestResolverError.URLDoesNotContainProperQueryItem(url: input.url.absoluteString)
        }
        
        /// Fetch a serialized request that could be OpenID Request or Credential Offer.
        let serializedRequest: Data = try await configuration.networking.fetch(url: requestUri,
                                                                               OpenIDRequestFetchNetworkOperation.self,
                                                                               additionalHeaders: additionalHeaders.getHeaders())
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
