/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import Foundation
import PromiseKit

#if canImport(VCEntities)
    import VCEntities
#endif

class FetchContractOperation: InternalNetworkOperation {
    typealias ResponseBody = SignedContract
    
    let decoder: ContractDecoder = ContractDecoder()
    let urlSession: URLSession
    var correlationVector: CorrelationHeader?
    var urlRequest: URLRequest
    
    init(withUrl urlStr: String,
         andCorrelationVector correlationVector: CorrelationHeader? = nil,
         session: URLSession = URLSession.shared) throws {
        
        guard let url = URL(unsafeString: urlStr) else {
            throw NetworkingError.invalidUrl(withUrl: urlStr)
        }
        
        self.urlSession = session
        self.correlationVector = correlationVector
        self.urlRequest = URLRequest(url: url)
        
        /// sets value in order to get a signed version of the contract
        self.urlRequest.addValue(Constants.SIGNED_CONTRACT_HEADER_VALUE,
                                 forHTTPHeaderField: Constants.SIGNED_CONTRACT_HEADER_FIELD)
    }
}
