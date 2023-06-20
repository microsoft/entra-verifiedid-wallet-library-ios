/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit
@testable import WalletLibrary

enum MockExchangeNetworkingError: Error {
    case doNotWantToResolveRealObject
}

class MockExchangeApiCalls: ExchangeNetworking {
    
    static var wasPostCalled = false
    
    func sendRequest(usingUrl url: String, withBody body: ExchangeRequest) -> Promise<VerifiableCredential> {
        Self.wasPostCalled = true
        return Promise { seal in
            seal.reject(MockExchangeNetworkingError.doNotWantToResolveRealObject)
        }
    }
}
