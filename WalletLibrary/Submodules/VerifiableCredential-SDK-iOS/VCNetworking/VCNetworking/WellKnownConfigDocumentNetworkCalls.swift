/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol WellKnownConfigDocumentNetworking {
    func getDocument(fromUrl domainUrl: String) async throws -> WellKnownConfigDocument
}

class WellKnownConfigDocumentNetworkCalls: WellKnownConfigDocumentNetworking {
    
    private let urlSession: URLSession
    private let correlationVector: VerifiedIdCorrelationHeader?
    
    init(correlationVector: VerifiedIdCorrelationHeader? = nil,
         urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
        self.correlationVector = correlationVector
    }
    
    func getDocument(fromUrl domainUrl: String) async throws -> WellKnownConfigDocument {
        let operation = try FetchWellKnownConfigDocumentOperation(withUrl: domainUrl,
                                                                  andCorrelationVector: correlationVector,
                                                                  session: urlSession)
        return try await operation.fire()
    }
}


