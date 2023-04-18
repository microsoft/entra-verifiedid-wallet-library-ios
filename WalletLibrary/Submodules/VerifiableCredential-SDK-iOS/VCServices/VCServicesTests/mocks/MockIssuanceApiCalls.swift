/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCNetworking
import VCEntities
import PromiseKit

@testable import VCServices

enum MockIssuanceNetworkingError: Error {
    case doNotWantToResolveRealObject
}

class MockIssuanceApiCalls: IssuanceNetworking {
    
    static var wasGetCalled = false
    static var wasPostResponseCalled = false
    static var wasPostCompletionResponseCalled = false
    
    func getRequest(withUrl url: String) -> Promise<SignedContract> {
        Self.wasGetCalled = true
        return Promise { seal in
            seal.reject(MockIssuanceNetworkingError.doNotWantToResolveRealObject)
        }
    }
    
    func sendResponse(usingUrl url: String, withBody body: IssuanceResponse) -> Promise<VerifiableCredential> {
        Self.wasPostResponseCalled = true
        return Promise { seal in
            seal.reject(MockIssuanceNetworkingError.doNotWantToResolveRealObject)
        }
    }
    
    public func sendCompletionResponse(usingUrl url: String,
                                       withBody body: IssuanceCompletionResponse) -> Promise<String?> {
        Self.wasPostCompletionResponseCalled = true
        return Promise { seal in
            seal.reject(MockIssuanceNetworkingError.doNotWantToResolveRealObject)
        }
    }
}
