/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public struct AttestationResponseDescriptor: Codable {
    public let accessTokens: RequestedAccessTokenMap?
    public let idTokens: RequestedIdTokenMap?
    public let presentations: [String: String]?
    public let selfIssued: RequestedSelfAttestedClaimMap?
    
    public init(accessTokens: RequestedAccessTokenMap? = nil,
                idTokens: RequestedIdTokenMap? = nil,
                presentations: [String: String]? = nil,
                selfIssued: RequestedSelfAttestedClaimMap? = nil) {
        self.accessTokens = accessTokens
        self.idTokens = idTokens
        self.presentations = presentations
        self.selfIssued = selfIssued
    }
}
