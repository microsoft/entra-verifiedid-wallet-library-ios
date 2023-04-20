/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import PromiseKit

#if canImport(VCEntities)
    import VCEntities
#endif

class FetchPresentationRequestOperation: InternalNetworkOperation {
    
    typealias ResponseBody = PresentationRequestToken
    
    private struct Constants {
        static let VersionNumberHeaderField = "prefer"
        static let VersionNumberHeaderValue = "JWT-interop-profile-0.0.1"
    }
    
    let decoder: PresentationRequestDecoder = PresentationRequestDecoder()
    let urlSession: URLSession
    var urlRequest: URLRequest
    var correlationVector: CorrelationHeader?
    
    public init(withUrl urlStr: String,
                andCorrelationVector cv: CorrelationHeader? = nil,
                session: URLSession = URLSession.shared) throws {
        
        guard let url = URL(unsafeString: urlStr) else {
            throw NetworkingError.invalidUrl(withUrl: urlStr)
        }
        
        self.urlRequest = URLRequest(url: url)
        self.urlSession = session
        self.correlationVector = cv
        
        /// sets value in order to get a signed version of the contract
        self.urlRequest.addValue(Constants.VersionNumberHeaderValue,
                                 forHTTPHeaderField: Constants.VersionNumberHeaderField)
    }
}
