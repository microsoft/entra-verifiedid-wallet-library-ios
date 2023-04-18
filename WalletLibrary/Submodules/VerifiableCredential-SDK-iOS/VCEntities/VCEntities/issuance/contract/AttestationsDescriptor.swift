/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct AttestationsDescriptor: Codable, Equatable {
    
    public let selfIssued: SelfIssuedClaimsDescriptor?
    public let presentations: [PresentationDescriptor]?
    public let idTokens: [IdTokenDescriptor]?
    public let accessTokens: [AccessTokenDescriptor]?
    
    public init(selfIssued: SelfIssuedClaimsDescriptor? = nil,
                presentations: [PresentationDescriptor]? = nil,
                idTokens: [IdTokenDescriptor]? = nil,
                accessTokens: [AccessTokenDescriptor]? = nil) {
        
        self.selfIssued = selfIssued
        self.presentations = presentations
        self.idTokens = idTokens
        self.accessTokens = accessTokens
    }
}
