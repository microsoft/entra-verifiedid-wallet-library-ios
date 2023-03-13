/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockConstraint: VerifiedIdConstraint {
    
    let doesMatchResult: Bool
    
    init(doesMatchResult: Bool) {
        self.doesMatchResult = doesMatchResult
    }
    
    func doesMatch(verifiedId: WalletLibrary.VerifiedId) -> Bool {
        return doesMatchResult
    }
}
