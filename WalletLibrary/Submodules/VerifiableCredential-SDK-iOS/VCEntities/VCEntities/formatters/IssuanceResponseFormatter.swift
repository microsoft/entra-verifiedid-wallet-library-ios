/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public protocol IssuanceResponseFormatting {
    func format(response: IssuanceResponseContainer, usingIdentifier identifier: Identifier) throws -> IssuanceResponse
}

public class IssuanceResponseFormatter: IssuanceResponseFormatting {
    
    private let signer: TokenSigning
    private let sdkLog: VCSDKLog
    private let headerFormatter = JwsHeaderFormatter()
    private let vpFormatter: IssuanceVPFormatter
    
    public init(signer: TokenSigning = Secp256k1Signer(),
                sdkLog: VCSDKLog = VCSDKLog.sharedInstance) {
        self.signer = signer
        self.vpFormatter = IssuanceVPFormatter(signer: signer)
        self.sdkLog = sdkLog
    }
    
    public func format(response: IssuanceResponseContainer, usingIdentifier identifier: Identifier) throws -> IssuanceResponse {
        
        guard let signingKey = identifier.didDocumentKeys.first else {
            throw FormatterError.noSigningKeyFound
        }
        
        return try createToken(response: response, usingIdentifier: identifier, andSignWith: signingKey)
    }
    
    private func createToken(response: IssuanceResponseContainer, usingIdentifier identifier: Identifier, andSignWith key: KeyContainer) throws -> IssuanceResponse {
        
        let headers = headerFormatter.formatHeaders(usingIdentifier: identifier, andSigningKey: key)
        let content = try self.formatClaims(response: response, usingIdentifier: identifier, andSigningKey: key)
        
        guard var token = JwsToken(headers: headers, content: content) else {
            throw FormatterError.unableToFormToken
        }
        
        try token.sign(using: self.signer, withSecret: key.keyReference)
        return token
    }
    
    private func formatClaims(response: IssuanceResponseContainer, usingIdentifier identifier: Identifier, andSigningKey key: KeyContainer) throws -> IssuanceResponseClaims {
        
        let publicKey = try signer.getPublicJwk(from: key.keyReference, withKeyId: key.keyId)
        let timeConstraints = TokenTimeConstraints(expiryInSeconds: response.expiryInSeconds)
        let attestations = try self.formatAttestations(response: response, usingIdentifier: identifier, andSignWith: key)
        
        var pin: String? = nil
        if response.issuanceIdToken != nil
        {
            pin = try response.issuancePin?.hash()
        }
        
        return IssuanceResponseClaims(publicKeyThumbprint: try publicKey.getThumbprint(),
                                      audience: response.audienceUrl,
                                      did: identifier.longFormDid,
                                      publicJwk: publicKey,
                                      contract: response.contractUri,
                                      jti: UUID().uuidString,
                                      attestations: attestations,
                                      pin: pin,
                                      iat: timeConstraints.issuedAt,
                                      exp: timeConstraints.expiration)
    }
    
    private func formatAttestations(response: IssuanceResponseContainer, usingIdentifier identifier: Identifier, andSignWith key: KeyContainer) throws -> AttestationResponseDescriptor? {
        
        var accessTokenMap: RequestedAccessTokenMap? = nil
        if !response.requestedAccessTokenMap.isEmpty {
            accessTokenMap = response.requestedAccessTokenMap
        }
        
        var idTokenMap: RequestedIdTokenMap? = nil
        if !response.requestedIdTokenMap.isEmpty {
            idTokenMap = response.requestedIdTokenMap
        }
        
        var selfIssuedMap: RequestedSelfAttestedClaimMap? = nil
        if !response.requestedSelfAttestedClaimMap.isEmpty {
            selfIssuedMap = response.requestedSelfAttestedClaimMap
        }

        if response.issuanceIdToken != nil {
            if idTokenMap == nil {
                idTokenMap = [:]
            }
            idTokenMap?[VCEntitiesConstants.SELF_ISSUED] = response.issuanceIdToken
        }

        let presentationsMap = try createPresentations(from: response, usingIdentifier: identifier, andSignWith: key)
        
        sdkLog.logVerbose(message: """
            Creating Issuance Response with:
            access_tokens: \(accessTokenMap?.count ?? 0)
            id_tokens: \(idTokenMap?.count ?? 0)
            self_issued claims: \(selfIssuedMap?.count ?? 0)
            verifiable credentials: \(presentationsMap?.count ?? 0)
            """)
        
        return AttestationResponseDescriptor(accessTokens: accessTokenMap,
                                             idTokens: idTokenMap,
                                             presentations: presentationsMap,
                                             selfIssued: selfIssuedMap)
    }
    
    private func createPresentations(from response: IssuanceResponseContainer, usingIdentifier identifier: Identifier, andSignWith key: KeyContainer) throws -> [String: String]? {
        
        guard !response.requestVCMap.isEmpty else {
            return nil
        }
        
        return Dictionary(try response.requestVCMap.map { requestedVCMapping in
            try self.createVerifiablePresentation(requestedVCMapping: requestedVCMapping,
                                                  issuer: response.contract.input.issuer,
                                                  expiration: response.expiryInSeconds,
                                                  identifier: identifier,
                                                  key: key)
            
        }) { first, _ in first }
    }
    
    private func createVerifiablePresentation(requestedVCMapping: RequestedVerifiableCredentialMapping,
                                              issuer: String,
                                              expiration: Int,
                                              identifier: Identifier,
                                              key: KeyContainer) throws -> (String, String) {
        
        let vp = try self.vpFormatter.format(toWrap: requestedVCMapping.vc,
                                             withAudience: issuer,
                                             withExpiryInSeconds: expiration,
                                             usingIdentifier: identifier,
                                             andSignWith: key)
        
        return (requestedVCMapping.inputDescriptorId, try vp.serialize())
        
    }
}
