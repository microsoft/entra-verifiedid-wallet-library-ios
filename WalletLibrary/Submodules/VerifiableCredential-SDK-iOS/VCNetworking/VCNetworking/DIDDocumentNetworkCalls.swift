/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit

#if canImport(VCEntities)
    import VCEntities
#endif

protocol DiscoveryNetworking {
    func getDocument(from identifier: String) -> Promise<IdentifierDocument>
}

class DIDDocumentNetworkCalls: DiscoveryNetworking {
    
    private let urlSession: URLSession
    private let correlationVector: CorrelationHeader?
    
    init(correlationVector: CorrelationHeader? = nil,
                urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
        self.correlationVector = correlationVector
    }
    
    func getDocument(from identifier: String) -> Promise<IdentifierDocument> {
        
        do {
            var operation = try FetchDIDDocumentOperation(withIdentifier: identifier,
                                                          andCorrelationVector: correlationVector,
                                                          session: self.urlSession)
            return operation.fire()
        } catch {
            return Promise { seal in
                seal.reject(error)
            }
        }
    }
}

