/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Network Operation for the Credential Metadata fetch request.
 */
struct CredentialMetadataFetchOperation: WalletLibraryFetchOperation
{
    typealias ResponseBody = CredentialMetadata
    
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
        self.urlRequest = URLRequest(url: url)
        
        /// Adds value to prefer header, appending if value already exists.
        let preferHeader = [OpenID4VCINetworkConstants.PreferHeaderField: OpenID4VCINetworkConstants.InteropProfileVersion]
        addHeadersToURLRequest(headers: preferHeader)
        
        addHeadersToURLRequest(headers: additionalHeaders)
    }
    
    static func buildCredentialMetadataEndpoint(url: String) -> URL?
    {
        let suffix = "/.well-known/openid-credential-issuer"
        if url.hasSuffix(suffix)
        {
            return URL(string: url)
        }
        else
        {
            return URL(string: "url\(suffix)")
        }
    }
}
