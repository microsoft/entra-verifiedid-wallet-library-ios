/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockVerifiedIdRequester: VerifiedIdRequester {
    
    enum MockVerifiedIdRequesterError: Error {
        case missingCallback
    }
    
    let sendRequestCallback: ((String) throws -> VerifiedId)?
    
    init(sendRequestCallback: ((String) throws -> VerifiedId)? = nil) {
        self.sendRequestCallback = sendRequestCallback
    }
    
    func send<Request>(request: Request) async throws -> VerifiedId {
        
        if let sendRequestCallback = sendRequestCallback {
            return try sendRequestCallback((request as? String) ?? "")
        }
        
        throw MockVerifiedIdRequesterError.missingCallback
    }
    
}
