/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

enum MockDiscoveryNetworkingError: Error {
    case doNotWantToResolveRealObject
}

class MockDiscoveryApiCalls: DiscoveryNetworking {
    
    static var wasGetCalled = false
    let resolveSuccessfully: Bool
    let identifierDocument: IdentifierDocument
    
    init(resolveSuccessfully: Bool = true,
         withIdentifierDocument document: IdentifierDocument = IdentifierDocument(service: [],
                                                                         verificationMethod: [],
                                                                         authentication: ["authentication"],
                                                                         id: "did:test:67453")) {
        self.resolveSuccessfully = resolveSuccessfully
        self.identifierDocument = document
    }
    
    func getDocument(from identifier: String) async throws -> IdentifierDocument {
        Self.wasGetCalled = true
        if self.resolveSuccessfully {
            return identifierDocument
        } else {
            throw MockDiscoveryNetworkingError.doNotWantToResolveRealObject
        }
    }
}

