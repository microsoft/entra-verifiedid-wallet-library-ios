/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class FetchWellKnownConfigDocumentOperation: InternalNetworkOperation {
    typealias ResponseBody = WellKnownConfigDocument
    
    let decoder = WellKnownConfigDocumentDecoder()
    let urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: VerifiedIdCorrelationHeader?
    
    init(withUrl urlStr: String,
         andCorrelationVector cv: VerifiedIdCorrelationHeader? = nil,
         session: URLSession) throws {
        
        /// If endpoint doesn't end with / add one.
        guard let baseUrl = URL(unsafeString: urlStr),
              var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            throw NetworkingError.invalidUrl(withUrl: urlStr)
        }
        
        /// replace path and remove query items.
        urlComponents.path = Constants.WELL_KNOWN_SUBDOMAIN
        urlComponents.queryItems = nil
        
        guard let url = urlComponents.url else {
            throw NetworkingError.invalidUrl(withUrl: urlStr)
        }
        
        self.urlRequest = URLRequest(url: url)
        self.urlSession = session
        self.correlationVector = cv
    }
}

