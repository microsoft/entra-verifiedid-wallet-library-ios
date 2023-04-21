/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit

#if canImport(VCEntities)
    import VCEntities
#endif

protocol IssuanceNetworking {
    func getRequest(withUrl url: String) -> Promise<SignedContract>
    func sendResponse(usingUrl url: String, withBody body: IssuanceResponse) -> Promise<VerifiableCredential>
    func sendCompletionResponse(usingUrl url: String, withBody nody: IssuanceCompletionResponse) -> Promise<String?>
}

class IssuanceNetworkCalls: IssuanceNetworking {

    private let urlSession: URLSession
    private let correlationVector: CorrelationHeader?
    
    init(correlationVector: CorrelationHeader? = nil,
                urlSession: URLSession = URLSession.shared) {
        self.correlationVector = correlationVector
        self.urlSession = urlSession
    }
    
    func getRequest(withUrl url: String) -> Promise<SignedContract> {
        do {
            var operation = try FetchContractOperation(withUrl: url,
                                                       andCorrelationVector: correlationVector,
                                                       session: self.urlSession)
            return operation.fire()
        } catch {
            return Promise { seal in
                seal.reject(error)
            }
        }
    }
    
    func sendResponse(usingUrl url: String, withBody body: IssuanceResponse) -> Promise<VerifiableCredential> {
        do {
            var operation = try PostIssuanceResponseOperation(usingUrl: url,
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
    
    func sendCompletionResponse(usingUrl url: String,
                                       withBody body: IssuanceCompletionResponse) -> Promise<String?> {
        do {
            var operation = try PostIssuanceCompletionResponseOperation(usingUrl: url,
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
