/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary
import VCEntities

class MockVerifiedIdRequester: VerifiedIdRequester {
    
    enum MockVerifiedIdRequesterError: Error {
        case missingCallback
    }
    
    let sendRequestCallback: ((String) throws -> VerifiedId)?
    
    let sendIssuanceResultCallback: ((IssuanceCompletionResponse) throws -> Void)?
    
    init(sendRequestCallback: ((String) throws -> VerifiedId)? = nil,
         sendIssuanceResultCallback: ((IssuanceCompletionResponse) throws -> Void)? = nil) {
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
        try sendIssuanceResultCallback?(result as! IssuanceCompletionResponse)
    }
}
