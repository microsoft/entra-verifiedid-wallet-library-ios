/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

#if canImport(VCEntities)
    import VCEntities
#endif

class PostExchangeRequestOperation: InternalPostNetworkOperation {
    typealias Encoder = ExchangeRequestEncoder
    typealias RequestBody = ExchangeRequest
    typealias ResponseBody = VerifiableCredential
    
    let decoder = IssuanceServiceResponseDecoder()
    let encoder = ExchangeRequestEncoder()
    let urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: CorrelationHeader?
    
    init(usingUrl urlStr: String,
                withBody body: ExchangeRequest,
                andCorrelationVector cv: CorrelationHeader? = nil,
                urlSession: URLSession = URLSession.shared) throws {
        
        guard let url = URL(unsafeString: urlStr) else {
            throw NetworkingError.invalidUrl(withUrl: urlStr)
        }
        
        self.urlRequest = URLRequest(url: url)
        self.urlRequest.httpMethod = Constants.POST
        self.urlRequest.httpBody = try self.encoder.encode(value: body)
        self.urlRequest.setValue(Constants.PLAIN_TEXT, forHTTPHeaderField: Constants.CONTENT_TYPE)
        
        self.urlSession = urlSession
        self.correlationVector = cv
    }
    

}
