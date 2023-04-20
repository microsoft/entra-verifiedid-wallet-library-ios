/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public struct IssuanceResponseContainer: ResponseContaining {
    public let contract: Contract
    public let contractUri: String
    let expiryInSeconds: Int
    public let audienceUrl: String
    public let audienceDid: String
    public var issuancePin: IssuancePin? = nil
    public var issuanceIdToken: String? = nil
    public var requestedIdTokenMap: RequestedIdTokenMap = [:]
    public var requestedAccessTokenMap: RequestedAccessTokenMap = [:]
    public var requestedSelfAttestedClaimMap: RequestedSelfAttestedClaimMap = [:]
    public var requestVCMap: RequestedVerifiableCredentialMap = []
    
    public init(from contract: Contract,
                contractUri: String,
                expiryInSeconds exp: Int = 3000) throws {
        self.contract = contract
        self.contractUri = contractUri
        self.expiryInSeconds = exp
        
        self.audienceUrl = contract.input.credentialIssuer
        self.audienceDid = contract.input.issuer
    }
}

public typealias IssuanceResponse = JwsToken<IssuanceResponseClaims>
