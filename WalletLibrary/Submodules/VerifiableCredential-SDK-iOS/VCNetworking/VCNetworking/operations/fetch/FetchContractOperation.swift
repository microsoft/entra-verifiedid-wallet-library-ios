/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

class FetchContractOperation: InternalNetworkOperation {
    typealias ResponseBody = SignedContract
    
    let decoder: ContractDecoder = ContractDecoder()
    let urlSession: URLSession
    var correlationVector: VerifiedIdCorrelationHeader?
    var urlRequest: URLRequest
    
    init(withUrl urlStr: String,
         andCorrelationVector correlationVector: VerifiedIdCorrelationHeader? = nil,
         session: URLSession) throws {
        
        guard let url = URL(unsafeString: urlStr) else 
        {
            throw VerifiedIdErrors.MalformedInput(message: "Invalid url: \(urlStr).").error
        }
        
        self.urlSession = session
        self.correlationVector = correlationVector
        self.urlRequest = URLRequest(url: url)
        
        /// sets value in order to get a signed version of the contract
        self.urlRequest.addValue(Constants.SIGNED_CONTRACT_HEADER_VALUE,
                                 forHTTPHeaderField: Constants.SIGNED_CONTRACT_HEADER_FIELD)
    }
}
