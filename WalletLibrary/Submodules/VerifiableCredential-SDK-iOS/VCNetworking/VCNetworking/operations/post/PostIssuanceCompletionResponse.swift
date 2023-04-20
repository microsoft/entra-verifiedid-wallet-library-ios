/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

#if canImport(VCEntities)
    import VCEntities
#endif

public class PostIssuanceCompletionResponseOperation: InternalPostNetworkOperation {
    
    typealias Encoder = IssuanceCompletionResponseEncoder
    public typealias RequestBody = IssuanceCompletionResponse
    public typealias ResponseBody = String?
    
    let decoder = BasicServiceResponseDecoder()
    let encoder = IssuanceCompletionResponseEncoder()
    let urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: CorrelationHeader?
    
    public init(usingUrl urlStr: String,
                withBody body: IssuanceCompletionResponse,
                andCorrelationVector cv: CorrelationHeader? = nil,
                urlSession: URLSession = URLSession.shared) throws {
        
        guard let url = URL(unsafeString: urlStr) else {
            throw NetworkingError.invalidUrl(withUrl: urlStr)
        }
        
        self.urlRequest = URLRequest(url: url)
        self.urlRequest.httpMethod = Constants.POST
        self.urlRequest.httpBody = try self.encoder.encode(value: body)
        self.urlRequest.setValue(Constants.JSON, forHTTPHeaderField: Constants.CONTENT_TYPE)
        
        self.urlSession = urlSession
        self.correlationVector = cv
    }
}
