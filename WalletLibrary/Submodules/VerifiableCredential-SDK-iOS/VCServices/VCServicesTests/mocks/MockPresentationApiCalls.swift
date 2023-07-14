/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit
@testable import WalletLibrary

enum MockPresentationNetworkingError: Error {
    case doNotWantToResolveRealObject
}

class MockPresentationApiCalls: PresentationNetworking {
    
    static var wasGetCalled = false
    static var wasPostCalled = false
    
    func getRequest(withUrl url: String) async throws -> PresentationRequestToken {
        Self.wasGetCalled = true
        throw MockPresentationNetworkingError.doNotWantToResolveRealObject
    }
    
    func sendResponse(usingUrl url: String, withBody body: PresentationResponse) async throws {
        Self.wasPostCalled = true
        throw MockPresentationNetworkingError.doNotWantToResolveRealObject
    }
}

