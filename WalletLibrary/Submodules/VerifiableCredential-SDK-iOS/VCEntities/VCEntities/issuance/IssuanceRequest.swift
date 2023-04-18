/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct IssuanceRequest {
    
    public let token: SignedContract
    
    public let content: Contract
    
    public let linkedDomainResult: LinkedDomainResult
    
    public init(from token: SignedContract, linkedDomainResult: LinkedDomainResult) {
        
        self.token = token
        self.content = token.content
        self.linkedDomainResult = linkedDomainResult
    }
}
