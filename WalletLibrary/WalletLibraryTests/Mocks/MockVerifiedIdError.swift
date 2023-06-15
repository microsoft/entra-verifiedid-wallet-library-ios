/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockVerifiedIdError: VerifiedIdError {
    
    let error: Error?
    
    init(error: Error? = nil) {
        self.error = error
        super.init(message: "mock error", code: "")
    }
    
}

