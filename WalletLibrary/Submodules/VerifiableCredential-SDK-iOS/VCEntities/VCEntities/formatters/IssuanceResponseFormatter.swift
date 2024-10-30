/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

protocol IssuanceResponseFormatting
{
    func format(response: IssuanceResponseContainer, identifier: HolderIdentifier) throws -> IssuanceResponse
}

class IssuanceResponseFormatter: IssuanceResponseFormatting 
{
    private let logger: WalletLibraryLogger
    private let headerFormatter: JwsHeaderFormatter
    private let vpFormatter: IssuanceVPFormatter
    
    init(logger: WalletLibraryLogger,
         headerFormatter: JwsHeaderFormatter = JwsHeaderFormatter(),
         vpFormatter: IssuanceVPFormatter = IssuanceVPFormatter())
    {
        self.logger = logger
        self.headerFormatter = headerFormatter
        self.vpFormatter = vpFormatter
    }
    
    func format(response: IssuanceResponseContainer, identifier: HolderIdentifier) throws -> IssuanceResponse
    {
        let headers = headerFormatter.formatHeaders(identifier: identifier)
        let content = try self.formatClaims(response: response, identifier: identifier)
        
        guard var token = JwsToken(headers: headers, content: content) else {
            throw FormatterError.unableToFormToken
        }
        
        try token.sign(using: identifier)
        return token
    }
 
    private func formatClaims(response: IssuanceResponseContainer, identifier: HolderIdentifier) throws -> IssuanceResponseClaims
    {
        guard let publicKey = try (identifier as? JWKExportable)?.exportPublicKey() else
        {
            throw VerifiedIdError(message: "", code: "")
        }
        
        let timeConstraints = TokenTimeConstraints(expiryInSeconds: response.expiryInSeconds)
        let attestations = try self.formatAttestations(response: response, identifier: identifier)
        
        var pin: String? = nil
        if response.issuanceIdToken != nil
        {
            pin = try response.issuancePin?.hash()
        }
        
        return IssuanceResponseClaims(publicKeyThumbprint: try publicKey.getThumbprint(),
                                      audience: response.audienceUrl,
                                      did: identifier.id,
                                      publicJwk: publicKey,
                                      contract: response.contractUri,
                                      jti: UUID().uuidString,
                                      attestations: attestations,
                                      pin: pin,
                                      iat: timeConstraints.issuedAt,
                                      exp: timeConstraints.expiration)
    }
    
    private func formatAttestations(response: IssuanceResponseContainer, identifier: HolderIdentifier) throws -> AttestationResponseDescriptor?
    {
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

        let presentationsMap = try createPresentations(from: response, identifier: identifier)
        
        logger.logVerbose(message: """
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
    
    private func createPresentations(from response: IssuanceResponseContainer, identifier: HolderIdentifier) throws -> [String: String]?
    {
        guard !response.requestVCMap.isEmpty else 
        {
            return nil
        }
        
        return Dictionary(try response.requestVCMap.map { requestedVCMapping in
            try self.createVerifiablePresentation(requestedVCMapping: requestedVCMapping,
                                                  issuer: response.contract.input.issuer,
                                                  expiration: response.expiryInSeconds,
                                                  identifier: identifier)
            
        }) { first, _ in first }
    }
    
    private func createVerifiablePresentation(requestedVCMapping: RequestedVerifiableCredentialMapping,
                                              issuer: String,
                                              expiration: Int,
                                              identifier: HolderIdentifier) throws -> (String, String) {
        
        let vp = try self.vpFormatter.format(toWrap: requestedVCMapping.vc,
                                             withAudience: issuer,
                                             withExpiryInSeconds: expiration,
                                             usingIdentifier: identifier)
        
        return (requestedVCMapping.inputDescriptorId, try vp.serialize())
        
    }
}
