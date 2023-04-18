/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

#if canImport(VCEntities)
    import VCEntities
#endif

class PostPresentationResponseOperation: InternalPostNetworkOperation {
    typealias Encoder = PresentationResponseEncoder
    typealias RequestBody = PresentationResponse
    typealias ResponseBody = String?
    
    private struct InternalConstants {
        static let VersionNumberHeaderField = "prefer"
        static let VersionNumberHeaderValue = "WACI4ION-0.0.1"
    }
    
    let decoder = BasicServiceResponseDecoder()
    let encoder = PresentationResponseEncoder()
    let urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: CorrelationHeader?
    
    public init(usingUrl urlStr: String,
                withBody body: PresentationResponse,
                andCorrelationVector cv: CorrelationHeader? = nil,
                urlSession: URLSession = URLSession.shared) throws {
        
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
}
