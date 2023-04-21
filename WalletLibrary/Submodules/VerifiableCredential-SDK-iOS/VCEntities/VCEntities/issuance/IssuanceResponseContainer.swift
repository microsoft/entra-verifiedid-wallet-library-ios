/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

struct IssuanceResponseContainer: ResponseContaining {
    let contract: Contract
    let contractUri: String
    let expiryInSeconds: Int
    let audienceUrl: String
    let audienceDid: String
    var issuancePin: IssuancePin? = nil
    var issuanceIdToken: String? = nil
    var requestedIdTokenMap: RequestedIdTokenMap = [:]
    var requestedAccessTokenMap: RequestedAccessTokenMap = [:]
    var requestedSelfAttestedClaimMap: RequestedSelfAttestedClaimMap = [:]
    var requestVCMap: RequestedVerifiableCredentialMap = []
    
    init(from contract: Contract,
         contractUri: String,
         expiryInSeconds exp: Int = 3000) throws {
        self.contract = contract
        self.contractUri = contractUri
        self.expiryInSeconds = exp
        
        self.audienceUrl = contract.input.credentialIssuer
        self.audienceDid = contract.input.issuer
    }
}

typealias IssuanceResponse = JwsToken<IssuanceResponseClaims>
