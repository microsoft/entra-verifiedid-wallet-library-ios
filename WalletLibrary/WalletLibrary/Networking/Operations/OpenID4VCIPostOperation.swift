/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Network Operation for the Credential Metadata fetch request.
 */
struct OpenID4VCIPostOperation: WalletLibraryPostOperation
{
    typealias Encoder = RawOpenID4VCIRequestEncoder
    
    typealias ResponseBody = RawOpenID4VCIResponse
    
    typealias RequestBody = RawOpenID4VCIRequest
    
    /// The decoder for the Credential Metadata.
    struct RawOpenID4VCIResponseDecoder: Decoding
    {
        func decode(data: Data) throws -> RawOpenID4VCIResponse
        {
            return try JSONDecoder().decode(RawOpenID4VCIResponse.self,
                                            from: data)
        }
    }
    
    /// The decoder for the Credential Metadata.
    struct RawOpenID4VCIRequestEncoder: Encoding
    {
        func encode(value: RawOpenID4VCIRequest) throws -> Data {
            return try JSONEncoder().encode(value)
        }
    }
    
    
    var decoder = RawOpenID4VCIResponseDecoder()
    
    var urlSession: URLSession
    
    var urlRequest: URLRequest
    
    var correlationVector: VerifiedIdCorrelationHeader?
    
    init(requestBody: RawOpenID4VCIRequest, 
         url: URL,
         additionalHeaders: [String : String]?,
         urlSession: URLSession,
         correlationVector: VerifiedIdCorrelationHeader?) {
        
        self.urlSession = urlSession
        self.correlationVector = correlationVector
        self.urlRequest = URLRequest(url: url)
        
        /// Adds value to prefer header, appending if value already exists.
        /// Adds value to prefer header, appending if value already exists.
        let preferHeader = [OpenID4VCINetworkConstants.PreferHeaderField: OpenID4VCINetworkConstants.InteropProfileVersion]
        addHeadersToURLRequest(headers: preferHeader)
        
        addHeadersToURLRequest(headers: additionalHeaders)
    }
}

