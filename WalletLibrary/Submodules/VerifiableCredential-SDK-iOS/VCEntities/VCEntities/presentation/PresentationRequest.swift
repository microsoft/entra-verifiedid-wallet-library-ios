/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct PresentationRequest {
    
    let token: PresentationRequestToken
    
    let content: PresentationRequestClaims
    
    let linkedDomainResult: LinkedDomainResult
    
    init(from token: PresentationRequestToken, linkedDomainResult: LinkedDomainResult) {
        self.token = token
        self.content = token.content
        self.linkedDomainResult = linkedDomainResult
    }
    
    func getPinRequiredLength() -> Int? {
        return token.content.pin?.length
    }
    
    func containsRequiredClaims() -> Bool {
        return token.content.idTokenHint != nil
    }
    
    func getPinSalt() -> String? {
        return token.content.pin?.salt
    }
}
