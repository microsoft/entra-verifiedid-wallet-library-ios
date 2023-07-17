/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

enum MockIssuanceNetworkingError: Error {
    case doNotWantToResolveRealObject
}

class MockIssuanceApiCalls: IssuanceNetworking {
    
    static var wasGetCalled = false
    static var wasPostResponseCalled = false
    static var wasPostCompletionResponseCalled = false
    
    func getRequest(withUrl url: String) async throws -> SignedContract {
        Self.wasGetCalled = true
        throw MockIssuanceNetworkingError.doNotWantToResolveRealObject
    }
    
    func sendResponse(usingUrl url: String, withBody body: IssuanceResponse) async throws -> VerifiableCredential {
        Self.wasPostResponseCalled = true
        throw MockIssuanceNetworkingError.doNotWantToResolveRealObject
    }
    
    func sendCompletionResponse(usingUrl url: String, withBody body: IssuanceCompletionResponse) async throws {
        Self.wasPostCompletionResponseCalled = true
        throw MockIssuanceNetworkingError.doNotWantToResolveRealObject
    }
}
