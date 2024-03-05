/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Network Operation for the Pre Authorization Token Retrieval.
 */
struct OpenID4VCIPreAuthTokenPostOperation: WalletLibraryPostOperation
{
    typealias RequestBody = PreAuthTokenRequest
    typealias ResponseBody = PreAuthTokenResponse
    
    /// Post body should be formatted as URL Encoded String.
    let encoder = FormURLEncodedRequestEncoder()
    
    let urlSession: URLSession
    
    var urlRequest: URLRequest
    
    var correlationVector: VerifiedIdCorrelationHeader?
    
    init(requestBody: PreAuthTokenRequest,
         url: URL,
         additionalHeaders: [String : String]?,
         urlSession: URLSession,
         correlationVector: VerifiedIdCorrelationHeader?) throws
    {
        
        self.urlSession = urlSession
        self.correlationVector = correlationVector
        self.urlRequest = URLRequest(url: url)
        self.urlRequest.httpMethod = Constants.POST
        self.urlRequest.httpBody = try self.encoder.encode(value: requestBody)
        self.urlRequest.setValue(Constants.FORM_URLENCODED,
                                 forHTTPHeaderField: Constants.CONTENT_TYPE)
        
        /// Adds value to prefer header, appending if value already exists.
        let preferHeader = [OpenID4VCINetworkConstants.PreferHeaderField: OpenID4VCINetworkConstants.InteropProfileVersion]
        addHeadersToURLRequest(headers: preferHeader)
        
        addHeadersToURLRequest(headers: additionalHeaders)
    }
}
