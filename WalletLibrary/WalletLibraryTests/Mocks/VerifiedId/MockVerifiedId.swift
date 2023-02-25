/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockVerifiedId: VerifiedId, Equatable {
    
    var id: String
    
    var expiresOn: Date?
    
    var issuedOn: Date
    
    func getClaims() -> [VerifiedIdClaim] {
        return []
    }
}
