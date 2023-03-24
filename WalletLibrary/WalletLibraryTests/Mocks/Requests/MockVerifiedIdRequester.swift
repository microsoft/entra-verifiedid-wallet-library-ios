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
    
    let sendIssuanceResultCallback: ((String) throws -> Void)?
    
    init(sendRequestCallback: ((String) throws -> VerifiedId)? = nil,
         sendIssuanceResultCallback: ((String) throws -> Void)? = nil) {
        self.sendRequestCallback = sendRequestCallback
        self.sendIssuanceResultCallback = sendIssuanceResultCallback
    }
    
    func send<Request>(request: Request) async throws -> VerifiedId {
        
        if let sendRequestCallback = sendRequestCallback {
            return try sendRequestCallback((request as? String) ?? "")
        }
        
        throw MockVerifiedIdRequesterError.missingCallback
    }
    
    func send<IssuanceResult>(result: IssuanceResult, to url: URL) async throws {
        try sendIssuanceResultCallback?((result as? String) ?? "")
    }
}
