/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/


import PromiseKit
#if canImport(VCNetworking)
    import VCNetworking
#endif

#if canImport(VCEntities)
    import VCEntities
#endif

class ExchangeService {
    
    private let formatter: ExchangeRequestFormatting
    private let apiCalls: ExchangeNetworking
    
    convenience init(correlationVector: CorrelationHeader? = nil,
                     urlSession: URLSession = URLSession.shared) {
        self.init(formatter: ExchangeRequestFormatter(),
                  apiCalls: ExchangeNetworkCalls(correlationVector: correlationVector,
                                                 urlSession: urlSession))
    }
    
    init(formatter: ExchangeRequestFormatting,
         apiCalls: ExchangeNetworking) {
        self.formatter = formatter
        self.apiCalls = apiCalls
    }
    
    func send(request: ExchangeRequestContainer) -> Promise<VerifiableCredential> {
        return firstly {
            self.formatExchangeResponse(request: request)
        }.then { signedToken in
            self.apiCalls.sendRequest(usingUrl:  request.audience, withBody: signedToken)
        }
    }
    
    private func formatExchangeResponse(request: ExchangeRequestContainer) -> Promise<ExchangeRequest> {
        return Promise { seal in
            seal.fulfill(try self.formatter.format(request: request))
        }
    }
}
