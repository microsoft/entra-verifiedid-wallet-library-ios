/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct AttestationsDescriptor: Codable, Equatable {
    
    let selfIssued: SelfIssuedClaimsDescriptor?
    let presentations: [PresentationDescriptor]?
    let idTokens: [IdTokenDescriptor]?
    let accessTokens: [AccessTokenDescriptor]?
    
    init(selfIssued: SelfIssuedClaimsDescriptor? = nil,
                presentations: [PresentationDescriptor]? = nil,
                idTokens: [IdTokenDescriptor]? = nil,
                accessTokens: [AccessTokenDescriptor]? = nil) {
        
        self.selfIssued = selfIssued
        self.presentations = presentations
        self.idTokens = idTokens
        self.accessTokens = accessTokens
    }
}
