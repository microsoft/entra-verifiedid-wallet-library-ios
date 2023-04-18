/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCNetworking
import VCEntities
import PromiseKit

@testable import VCServices

enum MockWellKnownConfigDocumentNetworkingError: Error {
    case doNotWantToResolveRealObject
    case unableToParseTestData
}

class MockWellKnownConfigDocumentApiCalls: WellKnownConfigDocumentNetworking {

    static var wasGetCalled = false
    let resolveSuccessfully: Bool
    
    init(resolveSuccessfully: Bool = true) {
        self.resolveSuccessfully = resolveSuccessfully
    }
    
    func getDocument(fromUrl domainUrl: String) -> Promise<WellKnownConfigDocument> {
        Self.wasGetCalled = true
        return Promise { seal in
            if self.resolveSuccessfully {
                let encodedTestWellKnownConfig = TestData.wellKnownConfig.rawValue.data(using: .ascii)!
                do {
                    let testWellKnownConfig = try JSONDecoder().decode(WellKnownConfigDocument.self,
                                                                   from: encodedTestWellKnownConfig)
                    seal.fulfill(testWellKnownConfig)
                }
                seal.reject(MockWellKnownConfigDocumentNetworkingError.unableToParseTestData)
            } else {
                seal.reject(MockWellKnownConfigDocumentNetworkingError.doNotWantToResolveRealObject)
            }
        }
    }
}

