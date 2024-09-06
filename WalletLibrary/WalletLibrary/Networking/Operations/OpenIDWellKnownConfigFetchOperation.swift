/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Network Operation for the Open ID Well Known Configuration fetch request.
 */
struct OpenIDWellKnownConfigFetchOperation: WalletLibraryFetchOperation
{
    typealias ResponseBody = OpenIDWellKnownConfiguration
    
    var urlSession: URLSession
    
    var urlRequest: URLRequest
    
    var correlationVector: VerifiedIdCorrelationHeader?
    
    init(url: URL,
         additionalHeaders: [String : String]?,
         urlSession: URLSession,
         correlationVector: VerifiedIdCorrelationHeader?)
    {
        self.urlSession = urlSession
        self.correlationVector = correlationVector
        
        let wellknownEndpoint = Self.buildWellKnownEndpoint(url: url)
        self.urlRequest = URLRequest(url: wellknownEndpoint)
        
        /// Adds value to prefer header, appending if value already exists.
        let preferHeader = [OpenID4VCINetworkConstants.PreferHeaderField: OpenID4VCINetworkConstants.InteropProfileVersion]
        addHeadersToURLRequest(headers: preferHeader)
        
        addHeadersToURLRequest(headers: additionalHeaders)
    }
    
    /// Append suffix to given URL if it does not already have it.
    private static func buildWellKnownEndpoint(url: URL) -> URL
    {
        let suffix = "/.well-known/openid-configuration"
        if url.path.hasSuffix(suffix)
        {
            return url
        }
        else
        {
            let newURL = url.appendingPathComponent(suffix)
            return newURL
        }
    }
}
