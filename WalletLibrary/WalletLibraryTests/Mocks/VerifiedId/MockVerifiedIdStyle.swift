/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockVerifiedIdStyle: VerifiedIdStyle, Equatable {
    
    let name: String
    
    init(name: String = "mockName") {
        self.name = name
    }
}
