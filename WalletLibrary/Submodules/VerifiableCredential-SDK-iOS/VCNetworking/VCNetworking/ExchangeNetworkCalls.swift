/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit

#if canImport(VCEntities)
    import VCEntities
#endif

protocol ExchangeNetworking {
    func sendRequest(usingUrl url: String, withBody body: ExchangeRequest) -> Promise<VerifiableCredential>
}

class ExchangeNetworkCalls: ExchangeNetworking {
    
    private let urlSession: URLSession
    private let correlationVector: VerifiedIdCorrelationHeader?
    
    init(correlationVector: VerifiedIdCorrelationHeader? = nil,
                urlSession: URLSession = URLSession.shared) {
        self.correlationVector = correlationVector
        self.urlSession = urlSession
    }
    
    func sendRequest(usingUrl url: String, withBody body: ExchangeRequest) -> Promise<VerifiableCredential> {
        do {
            var operation = try PostExchangeRequestOperation(usingUrl: url,
                                                             withBody: body,
                                                             andCorrelationVector: correlationVector,
                                                             urlSession: self.urlSession)
            return operation.fire()
        } catch {
            return Promise { seal in
                seal.reject(error)
            }
        }
    }
}
