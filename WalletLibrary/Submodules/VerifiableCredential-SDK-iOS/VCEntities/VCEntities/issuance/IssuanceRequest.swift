/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct IssuanceRequest {
    
    let token: SignedContract
    
    let content: Contract
    
    let linkedDomainResult: LinkedDomainResult
    
    init(from token: SignedContract, linkedDomainResult: LinkedDomainResult) {
        
        self.token = token
        self.content = token.content
        self.linkedDomainResult = linkedDomainResult
    }
}
