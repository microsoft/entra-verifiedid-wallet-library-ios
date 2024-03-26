/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockPresentationExchangeRequirement: PresentationExchangeRequirement
{
    var inputDescriptorId: String
    
    var format: PresentationExchangeVerifiedIdFormat = .JWT_VC
    
    var exclusivePresentationWith: [String]?
    
    init(inputDescriptorId: String, exclusivePresentationWith: [String]? = nil)
    {
        self.inputDescriptorId = inputDescriptorId
        self.exclusivePresentationWith = exclusivePresentationWith
    }
}
