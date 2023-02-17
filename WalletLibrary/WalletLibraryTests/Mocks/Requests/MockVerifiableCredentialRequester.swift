/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockVerifiableCredentialRequester: VerifiableCredentialRequester {
    
    enum MockVerifiableCredentialRequestError: Error {
        case missingCallback
    }
    
    let sendRequestCallback: ((String) throws -> WalletLibrary.VerifiableCredential)?
    
    init(sendRequestCallback: ((String) throws -> WalletLibrary.VerifiableCredential)? = nil) {
        self.sendRequestCallback = sendRequestCallback
    }
    
    func send<Request>(request: Request) async throws -> WalletLibrary.VerifiableCredential {
        
        if let sendRequestCallback = sendRequestCallback,
           let request = request as? String {
            return try sendRequestCallback(request)
        }
        
        throw MockVerifiableCredentialRequestError.missingCallback
    }
    
}
