/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCNetworking
import VCEntities
import PromiseKit

@testable import VCServices

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
    
    func getDocument(from identifier: String) -> Promise<IdentifierDocument> {
        Self.wasGetCalled = true
        return Promise { seal in
            if self.resolveSuccessfully {
                seal.fulfill(identifierDocument)
            } else {
                seal.reject(MockDiscoveryNetworkingError.doNotWantToResolveRealObject)
            }
        }
    }
}

