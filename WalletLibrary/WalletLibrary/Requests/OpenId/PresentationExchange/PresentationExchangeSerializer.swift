/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Visitor and builder used by RequestProcessors to serialize Requirements.
 */
class PresentationExchangeSerializer: RequestProcessorSerializing
{
    private enum Constants
    {
        static let JwtVc = "jwt_vc"
        static let JwtVp = "jwt_vp"
    }
    
    private let configuration: LibraryConfiguration
    
    private let vpFormatter: VerifiablePresentationFormatter
    
    private var partialSubmissionMap: [PartialSubmissionMapEntry]
    
    private let state: String
    
    private let audience: String = ""
    
    private let nonce: String = ""
    
    init(state: String,
         libraryConfiguration: LibraryConfiguration,
         vpFormatter: VerifiablePresentationFormatter)
    {
        self.state = state
        self.configuration = libraryConfiguration
        self.vpFormatter = vpFormatter
        self.partialSubmissionMap = []
    }
    
    func serialize<T>(requirement: Requirement, verifiedIdSerializer: any VerifiedIdSerializing<T>) throws
    {
        guard let peRequirement = requirement as? PresentationExchangeRequirement else
        {
            return
        }
        
        if let rawVC = try requirement.serialize(protocolSerializer: self,
                                                 verifiedIdSerializer: verifiedIdSerializer) as? String
        {
            let entry = PartialSubmissionMapEntry(rawVC: rawVC,
                                                  peRequirement: peRequirement)
            partialSubmissionMap.append(entry)
        }
    }
    
    func build() throws -> PresentationResponse
    {
        let identifier = try configuration.identifierManager.fetchOrCreateMasterIdentifier()
        
        guard let firstKey = identifier.didDocumentKeys.first else
        {
            throw IdentifierError.NoKeysInDocument()
        }
        
        let idToken = try buildIdToken()
        let vpTokens = try buildVpTokens(rawVCs: [],
                                         identifier: identifier.longFormDid,
                                         signingKey: firstKey)
        return PresentationResponse(idToken: idToken,
                                    vpTokens: vpTokens,
                                    state: state)
    }
    
    private func buildIdToken() throws -> PresentationResponseToken
    {
        throw VerifiedIdError(message: "", code: "")
    }
    
    private func buildVpTokens(rawVCs: [String],
                               identifier: String,
                               signingKey: KeyContainer) throws -> [VerifiablePresentation]
    {
        let vp = try vpFormatter.format(rawVCs: rawVCs,
                                        audience: audience,
                                        nonce: nonce,
                                        identifier: identifier,
                                        signingKey: signingKey)
        return [vp]
    }
//    
//    private func buildPresentationSubmission(presentationDefinitionId: String,
//                                             presentationDefinitionIndex: Int,
//                                             entry: [PartialSubmissionMapEntry]) -> PresentationSubmission {
//        
//        let inputDescriptorMap = entry.enumerated().map { (index, vcMapping) in
//            buildInputDescriptorMapping(id: vcMapping.peRequirement.inputDescriptorId,
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
//    private func buildInputDescriptorMapping(id: String,
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

struct PartialSubmissionMapEntry
{
    let rawVC: String
    
    let peRequirement: PresentationExchangeRequirement
}
