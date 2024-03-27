/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct PostPresentationResponseOperation: WalletLibraryPostOperation
{
    typealias Encoder = PresentationResponseEncoder
    typealias RequestBody = PresentationResponse
    typealias ResponseBody = String?
    
    let decoder = BasicServiceResponseDecoder()
    let encoder = PresentationResponseEncoder()
    let urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: VerifiedIdCorrelationHeader?
    
    init(usingUrl urlStr: String,
         withBody body: PresentationResponse,
         andCorrelationVector cv: VerifiedIdCorrelationHeader? = nil,
         urlSession: URLSession) throws {
        
        guard let url = URL(unsafeString: urlStr) else {
            throw NetworkingError.invalidUrl(withUrl: urlStr)
        }
        
        self.urlRequest = URLRequest(url: url)
        self.urlRequest.httpMethod = Constants.POST
        self.urlRequest.httpBody = try self.encoder.encode(value: body)
        self.urlRequest.setValue(Constants.FORM_URLENCODED, forHTTPHeaderField: Constants.CONTENT_TYPE)
        
        self.urlSession = urlSession
        self.correlationVector = cv
    }
    
    init(requestBody: PresentationResponse,
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
        addHeadersToURLRequest(headers: additionalHeaders)
    }
}
