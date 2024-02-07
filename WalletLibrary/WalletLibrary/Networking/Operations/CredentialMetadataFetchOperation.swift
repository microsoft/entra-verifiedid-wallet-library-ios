/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Network Operation to prefer the OpenID4VCI Request.
 */
struct CredentialMetadataFetchOperation: WalletLibraryFetchOperation
{
    typealias ResponseBody = CredentialMetadata
    
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
    }
}



