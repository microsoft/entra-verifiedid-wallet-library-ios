/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * Formats a Verifiable Presentation token in JWT format which adheres to the Presentation Exchange protocol.
 */
class PresentationExchangeIdTokenFormatter
{
    let signer: TokenSigning
    let headerFormatter = JwsHeaderFormatter()
    
    init(signer: TokenSigning = Secp256k1Signer())
    {
        self.signer = signer
    }
    
//    func format(entries: [PartialSubmissionMapEntry],
//                identifier: String,
//                signingKey: KeyContainer) throws -> PresentationResponseToken
//    {
//        let headers = headerFormatter.formatHeaders(identifier: identifier,
//                                                    signingKey: signingKey)
//        let content = try self.formatTokenContent(entries: entries,
//                                                  identifier: identifier,
//                                                  signingKey: signingKey)
//        
//        guard var token = JwsToken(headers: headers, content: content) else {
//            throw FormatterError.unableToFormToken
//        }
//        
//        try token.sign(using: signer, withSecret: signingKey.keyReference)
//        
//        return token
//    }
//    
//    private func formatTokenContent(entries: [PartialSubmissionMapEntry],
//                                    identifier: String) throws -> PresentationResponseClaims 
//    {
//        let timeConstraints = TokenTimeConstraints()
//        
//        var presentationDefinitionIndex: Int = 0
//        let vpTokensResponses = entries.enumerated().compactMap { (index, entry) in
//            let submission = formatPresentationSubmission(presentationDefinitionId: entry.peRequirement.inputDescriptorId,
//                                                               presentationDefinitionIndex: presentationDefinitionIndex,
//                                                               vcsRequested: mappings)
//            let vpTokenResponse = VPTokenResponseDescription(presentationSubmission: submission)
//            presentationDefinitionIndex = presentationDefinitionIndex + 1
//            return vpTokenResponse
//        }
//        
//        return PresentationResponseClaims(subject: identifier.longFormDid,
//                                          audience: response.audienceDid,
//                                          vpTokenDescription: vpTokensResponses,
//                                          nonce: response.nonce,
//                                          iat: timeConstraints.issuedAt,
//                                          exp: timeConstraints.expiration)
//    }
//    
//    private func formatPresentationSubmission(presentationDefinitionId: String,
//                                             presentationDefinitionIndex: Int,
//                                             entry: [PartialSubmissionMapEntry]) -> PresentationSubmission {
//        
//        let inputDescriptorMap = entry.enumerated().map { (index, vcMapping) in
//            formatInputDescriptorMapping(id: vcMapping.peRequirement.inputDescriptorId,
//                                        presentationDefinitionIndex: presentationDefinitionIndex,
//                                        vcIndex: index)
//        }
//        
//        let submission = PresentationSubmission(id: UUID().uuidString,
//                                                definitionId: presentationDefinitionId,
//                                                inputDescriptorMap: inputDescriptorMap)
//        
//        return submission
//    }
//    
//    // double check with services team about what this object looks like.
//    private func formatInputDescriptorMapping(id: String,
//                                             presentationDefinitionIndex: Int,
//                                             vcIndex: Int) -> InputDescriptorMapping
//    {
//        let nestedInputDescriptorMapping = NestedInputDescriptorMapping(id: id,
//                                                                        format: Constants.JwtVc,
//                                                                        path: "$.verifiableCredential[\(vcIndex)]")
//        
//        return InputDescriptorMapping(id: id,
//                                      format: Constants.JwtVp,
//                                      path: "\("Constants.SimplePath")[\(presentationDefinitionIndex)]",
//                                      pathNested: nestedInputDescriptorMapping)
//    }
}
