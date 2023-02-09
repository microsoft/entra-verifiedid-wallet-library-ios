/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockVerifiedIdRequestContent: VerifiedIdRequestContent {
    
    var style: WalletLibrary.RequesterStyle
    
    var requirement: WalletLibrary.Requirement
    
    var rootOfTrust: WalletLibrary.RootOfTrust
    
    init(style: RequesterStyle, requirement: Requirement, rootOfTrust: RootOfTrust) {
        self.style = style
        self.requirement = requirement
        self.rootOfTrust = rootOfTrust
    }
}
