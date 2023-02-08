/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockInput: VerifiedIdClientInput {
    
    let mockData: String
    
    init(mockData: String) {
        self.mockData = mockData
    }
}
