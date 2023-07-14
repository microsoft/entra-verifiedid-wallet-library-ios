/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

protocol DiscoveryNetworking {
    func getDocument(from identifier: String) async throws -> IdentifierDocument
}

class DIDDocumentNetworkCalls: DiscoveryNetworking {
    
    private let urlSession: URLSession
    private let correlationVector: VerifiedIdCorrelationHeader?
    
    init(correlationVector: VerifiedIdCorrelationHeader? = nil,
         urlSession: URLSession) {
        self.urlSession = urlSession
        self.correlationVector = correlationVector
    }
    
    func getDocument(from identifier: String) async throws -> IdentifierDocument {
        let operation = try FetchDIDDocumentOperation(withIdentifier: identifier,
                                                      andCorrelationVector: correlationVector,
                                                      session: self.urlSession)
        return try await operation.fire()
    }
}


