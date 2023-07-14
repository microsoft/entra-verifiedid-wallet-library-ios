/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

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
    
    func getDocument(fromUrl domainUrl: String) async throws -> WellKnownConfigDocument {
        
        Self.wasGetCalled = true
        
        if self.resolveSuccessfully {
            do {
                let encodedTestWellKnownConfig = VCServicesTestData.wellKnownConfig.rawValue.data(using: .ascii)!
                let testWellKnownConfig = try JSONDecoder().decode(WellKnownConfigDocument.self,
                                                                   from: encodedTestWellKnownConfig)
                return testWellKnownConfig
            } catch {
                throw MockWellKnownConfigDocumentNetworkingError.unableToParseTestData
            }
        } else {
            throw MockWellKnownConfigDocumentNetworkingError.doNotWantToResolveRealObject
        }
    }
}

