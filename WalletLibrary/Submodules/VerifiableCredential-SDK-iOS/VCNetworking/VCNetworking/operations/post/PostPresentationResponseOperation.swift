/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class PostPresentationResponseOperation: InternalPostNetworkOperation {
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
         additionalHeaders: [String: String]? = nil,
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
        
        for header in (additionalHeaders ?? [:])
        {
            self.urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }
    }
}
