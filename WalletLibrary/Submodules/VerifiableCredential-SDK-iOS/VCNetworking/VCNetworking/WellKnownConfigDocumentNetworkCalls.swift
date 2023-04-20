/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit

#if canImport(VCEntities)
    import VCEntities
#endif

public protocol WellKnownConfigDocumentNetworking {
    func getDocument(fromUrl domainUrl: String) -> Promise<WellKnownConfigDocument>
}

public class WellKnownConfigDocumentNetworkCalls: WellKnownConfigDocumentNetworking {
    
    private let urlSession: URLSession
    private let correlationVector: CorrelationHeader?
    
    public init(correlationVector: CorrelationHeader? = nil,
                urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
        self.correlationVector = correlationVector
    }
    
    public func getDocument(fromUrl domainUrl: String) -> Promise<WellKnownConfigDocument> {
        do {
            var operation = try FetchWellKnownConfigDocumentOperation(withUrl: domainUrl,
                                                                      andCorrelationVector: correlationVector,
                                                                      session: urlSession)
            return operation.fire()
        } catch {
            return Promise { seal in
                seal.reject(error)
            }
        }
    }
}


