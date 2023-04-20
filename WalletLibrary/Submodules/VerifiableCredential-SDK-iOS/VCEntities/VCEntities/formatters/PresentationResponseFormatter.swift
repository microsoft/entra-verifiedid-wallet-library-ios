/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public protocol PresentationResponseFormatting {
    func format(response: PresentationResponseContainer, usingIdentifier identifier: Identifier) throws -> PresentationResponse
}

public class PresentationResponseFormatter: PresentationResponseFormatting {
    
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
    
    public init(signer: TokenSigning = Secp256k1Signer(),
                sdkLog: VCSDKLog = VCSDKLog.sharedInstance) {
        self.signer = signer
        self.vpFormatter = VerifiablePresentationFormatter(signer: signer)
        self.sdkLog = sdkLog
    }
    
    public func format(response: PresentationResponseContainer, usingIdentifier identifier: Identifier) throws -> PresentationResponse {
        
        guard let signingKey = identifier.didDocumentKeys.first else {
            throw FormatterError.noSigningKeyFound
        }
        
        guard let state = response.request?.content.state else {
            throw FormatterError.noStateInRequest
        }
        
        let idToken = try createIdToken(from: response, usingIdentifier: identifier, andSignWith: signingKey)
        let vpToken = try createVpToken(from: response, usingIdentifier: identifier, andSignWith: signingKey)

        return PresentationResponse(idToken: idToken,
                                    vpToken: vpToken,
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
    
    private func createVpToken(from response: PresentationResponseContainer,
                               usingIdentifier identifier: Identifier,
                               andSignWith key: KeyContainer) throws -> VerifiablePresentation {
        
        return try vpFormatter.format(toWrap: response.requestVCMap,
                                      withAudience: response.audienceDid,
                                      withNonce: response.nonce,
                                      withExpiryInSeconds: response.expiryInSeconds,
                                      usingIdentifier: identifier,
                                      andSignWith: key)
    }
    
    private func formatClaims(from response: PresentationResponseContainer, usingIdentifier identifier: Identifier, andSignWith key: KeyContainer) throws -> PresentationResponseClaims {
        
        let timeConstraints = TokenTimeConstraints(expiryInSeconds: response.expiryInSeconds)
        
        let presentationSubmission = self.formatPresentationSubmission(from: response, keyType: VCEntitiesConstants.JWT)
        let vpTokenDescription = VPTokenResponseDescription(presentationSubmission: presentationSubmission)
        
        return PresentationResponseClaims(subject: identifier.longFormDid,
                                          audience: response.audienceDid,
                                          vpTokenDescription: vpTokenDescription,
                                          nonce: response.nonce,
                                          iat: timeConstraints.issuedAt,
                                          exp: timeConstraints.expiration)
    }
    
    private func formatPresentationSubmission(from response: PresentationResponseContainer, keyType: String) -> PresentationSubmission? {
        
        guard !response.requestVCMap.isEmpty else {
            return nil
        }
        
        let inputDescriptorMap = response.requestVCMap.enumerated().map { (index, vcMapping) in
            createInputDescriptorMapping(id: vcMapping.inputDescriptorId, index: index)
        }
        
        sdkLog.logVerbose(message: """
            Creating Presentation Response with:
            verifiable credentials: \(response.requestVCMap.count)
            """)
        
        let submission = PresentationSubmission(id: UUID().uuidString,
                                                definitionId: response.presentationDefinitionId,
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
