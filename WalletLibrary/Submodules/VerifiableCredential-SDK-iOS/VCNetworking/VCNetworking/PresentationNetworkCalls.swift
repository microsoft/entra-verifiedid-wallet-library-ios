/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit

#if canImport(VCEntities)
    import VCEntities
#endif

public protocol PresentationNetworking {
    func getRequest(withUrl url: String) -> Promise<PresentationRequestToken>
    func sendResponse(usingUrl url: String, withBody body: PresentationResponse) -> Promise<String?>
}

public class PresentationNetworkCalls: PresentationNetworking {

    private let urlSession: URLSession
    private let correlationVector: CorrelationHeader?
    
    public init(correlationVector: CorrelationHeader? = nil,
                urlSession: URLSession = URLSession.shared) {
        self.correlationVector = correlationVector
        self.urlSession = urlSession
    }
    
    public func getRequest(withUrl url: String) -> Promise<PresentationRequestToken> {
        do {
            var operation = try FetchPresentationRequestOperation(withUrl: url,
                                                                  andCorrelationVector: correlationVector,
                                                                  session: urlSession)
            return operation.fire()
        } catch {
            return Promise { seal in
                seal.reject(error)
            }
        }
    }
    
    public func sendResponse(usingUrl url: String, withBody body: PresentationResponse) -> Promise<String?> {
        do {
            var operation = try PostPresentationResponseOperation(usingUrl: url,
                                                                  withBody: body,
                                                                  andCorrelationVector: correlationVector,
                                                                  urlSession: urlSession)
            return operation.fire()
        } catch {
            return Promise { seal in
                seal.reject(error)
            }
        }
    }
}

