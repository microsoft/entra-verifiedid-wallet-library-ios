/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

struct AttestationResponseDescriptor: Codable {
    let accessTokens: RequestedAccessTokenMap?
    let idTokens: RequestedIdTokenMap?
    let presentations: [String: String]?
    let selfIssued: RequestedSelfAttestedClaimMap?
    
    init(accessTokens: RequestedAccessTokenMap? = nil,
                idTokens: RequestedIdTokenMap? = nil,
                presentations: [String: String]? = nil,
                selfIssued: RequestedSelfAttestedClaimMap? = nil) {
        self.accessTokens = accessTokens
        self.idTokens = idTokens
        self.presentations = presentations
        self.selfIssued = selfIssued
    }
}
