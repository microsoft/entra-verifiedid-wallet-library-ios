/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockConstraint: VerifiedIdConstraint {
    
    enum MockConstraintError: Error {
        case expectedToThrow
    }
    
    let doesMatchResult: Bool
    
    let matchesError: Error?
    
    init(doesMatchResult: Bool, matchesError: Error? = nil) {
        self.doesMatchResult = doesMatchResult
        /// If does not match, always throw something.
        if !doesMatchResult {
            self.matchesError = matchesError ?? MockConstraintError.expectedToThrow
        } else {
            self.matchesError = nil
        }
    }
    
    func doesMatch(verifiedId: WalletLibrary.VerifiedId) -> Bool {
        return doesMatchResult
    }
    
    func matches(verifiedId: WalletLibrary.VerifiedId) throws {
        if let matchesError = matchesError {
            throw matchesError
        }
    }
}
