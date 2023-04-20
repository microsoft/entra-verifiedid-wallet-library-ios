/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public struct PresentationRequest {
    
    public let token: PresentationRequestToken
    
    public let content: PresentationRequestClaims
    
    public let linkedDomainResult: LinkedDomainResult
    
    public init(from token: PresentationRequestToken, linkedDomainResult: LinkedDomainResult) {
        self.token = token
        self.content = token.content
        self.linkedDomainResult = linkedDomainResult
    }
    
    public func getPinRequiredLength() -> Int? {
        return token.content.pin?.length
    }
    
    public func containsRequiredClaims() -> Bool {
        return token.content.idTokenHint != nil
    }
    
    public func getPinSalt() -> String? {
        return token.content.pin?.salt
    }
}
