/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Visitor and builder used by RequestProcessors to serialize Requirements.
 */
class PresentationExchangeSerializer: RequestProcessorSerializing
{
    private let configuration: LibraryConfiguration
    
    private let vpFormatter: VerifiablePresentationFormatter
    
    private var vpBuilders: [VerifiablePresentationBuilder]
    
    private let state: String
    
    private let audience: String = ""
    
    private let nonce: String = ""
    
    private let definitionId: String = ""
    
    init(state: String,
         libraryConfiguration: LibraryConfiguration,
         vpFormatter: VerifiablePresentationFormatter)
    {
        self.state = state
        self.configuration = libraryConfiguration
        self.vpFormatter = vpFormatter
        self.vpBuilders = []
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
            let entry = PartialInputDescriptor(rawVC: rawVC,
                                                  peRequirement: peRequirement)
            addToVPGroupings(entry: entry)
        }
    }
    
    private func addToVPGroupings(entry: PartialInputDescriptor)
    {
        for group in vpBuilders
        {
            if group.canInclude(entry: entry)
            {
                group.add(entry: entry)
                return
            }
        }
        
        let newBuilder = VerifiablePresentationBuilder(index: vpBuilders.count)
        newBuilder.add(entry: entry)
        vpBuilders.append(newBuilder)
    }
    
    func build() throws -> PresentationResponse
    {
        let identifier = try configuration.identifierManager.fetchOrCreateMasterIdentifier()
        
        guard let firstKey = identifier.didDocumentKeys.first else
        {
            throw IdentifierError.NoKeysInDocument()
        }
        
        let idToken = try buildIdToken()
        let vpTokens = try buildVpTokens(identifier: identifier.longFormDid,
                                         signingKey: firstKey)
        return PresentationResponse(idToken: idToken,
                                    vpTokens: vpTokens,
                                    state: state)
    }
    
    private func buildIdToken() throws -> PresentationResponseToken
    {
        let inputDescriptors = vpBuilders.flatMap { $0.buildInputDescriptors() }
        let submission = PresentationSubmission(id: UUID().uuidString,
                                                definitionId: definitionId,
                                                inputDescriptorMap: inputDescriptors)
        
        throw VerifiedIdError(message: "", code: "")
    }
    
    private func buildVpTokens(identifier: String,
                               signingKey: KeyContainer) throws -> [VerifiablePresentation]
    {
        return try vpBuilders.map { vcGroup in
            let rawVcsInGroup = vcGroup.partials.map { $0.rawVC }
            return try vpFormatter.format(rawVCs: rawVcsInGroup,
                                          audience: audience,
                                          nonce: nonce,
                                          identifier: identifier,
                                          signingKey: signingKey)
        }
    }
}
