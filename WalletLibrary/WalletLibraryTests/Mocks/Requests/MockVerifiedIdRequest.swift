/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockVerifiedIdRequest: VerifiedIdRequest {
    
    var style: RequesterStyle
    
    var requirement: Requirement
    
    var rootOfTrust: RootOfTrust
    
    init(style: RequesterStyle = MockRequesterStyle(requester: ""),
         requirement: Requirement = MockRequirement(id: ""),
         rootOfTrust: RootOfTrust = RootOfTrust(verified: false, source: "")) {
        self.style = style
        self.requirement = requirement
        self.rootOfTrust = rootOfTrust
    }
    
    func isSatisfied() -> Bool {
        return false
    }
    
    func complete() async -> Result<Void, Error> {
        return Result.success(Void())
    }
    
    func cancel(message: String?) -> Result<Void, Error> {
        return Result.success(Void())
    }
}
