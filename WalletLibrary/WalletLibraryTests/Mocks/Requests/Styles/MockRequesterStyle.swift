/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockRequesterStyle: RequesterStyle, Equatable {
    
    let requester: String
    
    init(requester: String) {
        self.requester = requester
    }
}
