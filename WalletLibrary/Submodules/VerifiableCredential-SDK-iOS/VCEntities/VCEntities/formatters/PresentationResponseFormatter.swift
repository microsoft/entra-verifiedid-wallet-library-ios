/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

class PresentationResponseFormatter {
    
    private struct Constants {
        static let CredentialEncoding = "base64Url"
        static let CredentialPath = "$.attestations.presentations."
        static let JwtVc = "jwt_vc"
        static let JwtVp = "jwt_vp"
        static let SimplePath = "$"
    }
    
    let signer: TokenSigning
    let vpFormatter: VerifiablePresentationFormatter
    let sdkLog: VCSDKLog
    let headerFormatter = JwsHeaderFormatter()
    
    init(signer: TokenSigning = Secp256k1Signer(),
         sdkLog: VCSDKLog) {
        self.signer = signer
        self.vpFormatter = VerifiablePresentationFormatter(signer: signer)
        self.sdkLog = sdkLog
    }
    
    func format(response: PresentationResponseContainer, usingIdentifier identifier: Identifier) throws -> PresentationResponse {
        
        guard let signingKey = identifier.didDocumentKeys.first else {
            throw FormatterError.noSigningKeyFound
        }
        
        guard let state = response.request?.content.state else {
            throw FormatterError.noStateInRequest
        }
        
        let vpTokens = try self.createVpTokens(from: response,
                                               usingIdentifier: identifier,
                                               andSignWith: signingKey)
        
        let idToken = try createIdToken(from: response,
                                        usingIdentifier: identifier,
                                        andSignWith: signingKey)
        
        return PresentationResponse(idToken: idToken,
                                    vpTokens: vpTokens,
                                    state: state)
    }
    
    private func createIdToken(from response: PresentationResponseContainer,
                               usingIdentifier identifier: Identifier,
                               andSignWith key: KeyContainer) throws -> JwsToken<PresentationResponseClaims> {
        
        let headers = headerFormatter.formatHeaders(usingIdentifier: identifier, andSigningKey: key)
        let content = try self.formatClaims(from: response, usingIdentifier: identifier, andSignWith: key)
        
        guard var token = JwsToken(headers: headers, content: content) else {
            throw FormatterError.unableToFormToken
        }
        
        try token.sign(using: self.signer, withSecret: key.keyReference)
        
        return token
    }
    
    private func createVpTokens(from response: PresentationResponseContainer,
                                usingIdentifier identifier: Identifier,
                                andSignWith key: KeyContainer) throws -> [VerifiablePresentation] {
        
        return try response.requestVCMap.compactMap { presentationSubmissionId, mappings in
            try vpFormatter.format(toWrap: mappings,
                                   withAudience: response.audienceDid,
                                   withNonce: response.nonce,
                                   withExpiryInSeconds: response.expiryInSeconds,
                                   usingIdentifier: identifier,
                                   andSignWith: key)
        }
    }
    
    private func formatClaims(from response: PresentationResponseContainer, usingIdentifier identifier: Identifier, andSignWith key: KeyContainer) throws -> PresentationResponseClaims {
        
        let timeConstraints = TokenTimeConstraints(expiryInSeconds: response.expiryInSeconds)
        
        let presentationSubmissions = response.requestVCMap.compactMap { id, mappings in
            self.formatPresentationSubmission(presentationDefinitionId: id, vcsRequested: mappings)
        }
        
        let vpTokenDescription = VPTokenResponseDescription(presentationSubmission: presentationSubmissions)
        
        return PresentationResponseClaims(subject: identifier.longFormDid,
                                          audience: response.audienceDid,
                                          vpTokenDescription: vpTokenDescription,
                                          nonce: response.nonce,
                                          iat: timeConstraints.issuedAt,
                                          exp: timeConstraints.expiration)
    }
    
    private func formatPresentationSubmission(presentationDefinitionId: String,
                                              vcsRequested: [RequestedVerifiableCredentialMapping]) -> PresentationSubmission? {
        
        guard !vcsRequested.isEmpty else {
            return nil
        }
        
        let inputDescriptorMap = vcsRequested.enumerated().map { (index, vcMapping) in
            createInputDescriptorMapping(id: vcMapping.inputDescriptorId, index: index)
        }
        
        sdkLog.logVerbose(message: """
            Creating Presentation Submission with:
            verifiable credentials: \(inputDescriptorMap.count)
            """)
        
        let submission = PresentationSubmission(id: UUID().uuidString,
                                                definitionId: presentationDefinitionId,
                                                inputDescriptorMap: inputDescriptorMap)
        
        return submission
    }
    
    private func createInputDescriptorMapping(id: String, index: Int) -> InputDescriptorMapping {
        let nestedInputDescriptorMapping = NestedInputDescriptorMapping(id: id,
                                                                        format: Constants.JwtVc,
                                                                        path: "$.verifiableCredential[\(index)]")
        
        return InputDescriptorMapping(id: id,
                                      format: Constants.JwtVp,
                                      path: Constants.SimplePath,
                                      pathNested: nestedInputDescriptorMapping)
    }
}
