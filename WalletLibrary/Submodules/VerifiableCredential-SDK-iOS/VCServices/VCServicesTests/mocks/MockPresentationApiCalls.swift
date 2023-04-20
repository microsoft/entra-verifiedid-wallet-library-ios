/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCNetworking
import VCEntities
import PromiseKit

@testable import VCServices

enum MockPresentationNetworkingError: Error {
    case doNotWantToResolveRealObject
}

class MockPresentationApiCalls: PresentationNetworking {
    
    static var wasGetCalled = false
    static var wasPostCalled = false
    
    func getRequest(withUrl url: String) -> Promise<PresentationRequestToken> {
        Self.wasGetCalled = true
        return Promise { seal in
            seal.reject(MockPresentationNetworkingError.doNotWantToResolveRealObject)
        }
    }
    
    func sendResponse(usingUrl url: String, withBody body: PresentationResponse) -> Promise<String?> {
        Self.wasPostCalled = true
        return Promise { seal in
            seal.reject(MockPresentationNetworkingError.doNotWantToResolveRealObject)
        }
    }
}

