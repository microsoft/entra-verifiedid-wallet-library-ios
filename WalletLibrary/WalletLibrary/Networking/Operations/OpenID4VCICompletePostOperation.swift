/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Network Operation for the Credential Metadata fetch request.
 */
struct OpenID4VCICompletePostOperation: WalletLibraryPostOperation
{
    typealias RequestBody = OpenID4VCICompletionRequest
    typealias ResponseBody = Data
    
    let urlSession: URLSession
    
    var urlRequest: URLRequest
    
    var correlationVector: VerifiedIdCorrelationHeader?
    
    init(requestBody: OpenID4VCICompletionRequest,
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
        self.urlRequest.setValue(Constants.JSON, forHTTPHeaderField: Constants.CONTENT_TYPE)
        
        /// Adds value to prefer header, appending if value already exists.
        let preferHeader = [OpenID4VCINetworkConstants.PreferHeaderField: OpenID4VCINetworkConstants.InteropProfileVersion]
        addHeadersToURLRequest(headers: preferHeader)
        
        addHeadersToURLRequest(headers: additionalHeaders)
    }
}
