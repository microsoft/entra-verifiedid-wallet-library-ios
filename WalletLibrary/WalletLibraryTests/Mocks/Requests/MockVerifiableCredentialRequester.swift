/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary
import VCEntities

class MockVerifiableCredentialRequester: VerifiableCredentialRequester {
    
    let sendRequestCallback: ((String) throws -> WalletLibrary.VerifiableCredential)?
    
    init(sendRequestCallback: ((String) throws -> WalletLibrary.VerifiableCredential)? = nil) {
        self.sendRequestCallback = sendRequestCallback
    }
    
    func send<Request>(request: Request) async throws -> WalletLibrary.VerifiableCredential {
        
        if let sendRequestCallback = sendRequestCallback {
            return try sendRequestCallback("test")
        }
        
        throw VerifiedIdClientError.TODO(message: "add")
    }
    
}
