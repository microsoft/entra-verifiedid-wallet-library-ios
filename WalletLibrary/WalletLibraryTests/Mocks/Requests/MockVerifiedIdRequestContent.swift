/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockVerifiedIdRequestContent: VerifiedIdRequestContent {
    
    var style: RequesterStyle
    
    var requirement: Requirement
    
    var rootOfTrust: RootOfTrust
    
    init(style: RequesterStyle, requirement: Requirement, rootOfTrust: RootOfTrust) {
        self.style = style
        self.requirement = requirement
        self.rootOfTrust = rootOfTrust
    }
}
