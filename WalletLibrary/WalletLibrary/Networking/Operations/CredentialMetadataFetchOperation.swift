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
    
    /// The decoder for the Credential Metadata.
    struct CredentialMetadataDecoder: Decoding
    {
        typealias ResponseBody = CredentialMetadata
        
        func decode(data: Data) throws -> CredentialMetadata
        {
            return try JSONDecoder().decode(CredentialMetadata.self, from: data)
        }
    }
    
    var decoder = CredentialMetadataDecoder()
    
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
        urlRequest.addValue(OpenID4VCINetworkConstants.InteropProfileVersion,
                            forHTTPHeaderField: OpenID4VCINetworkConstants.PreferHeaderField)
        
        addHeadersToURLRequest(headers: additionalHeaders)
    }
}
