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
    
    private var vpBuilders: [VerifiablePresentationBuilder]
    
    private let idTokenBuilder: PresentationExchangeIdTokenBuilder
    
    private let state: String
    
    private let audience: String
    
    private let nonce: String
    
    private let definitionId: String
    
    init(definitionId: String,
         state: String,
         audience: String,
         nonce: String,
         libraryConfiguration: LibraryConfiguration)
    {
        self.definitionId = definitionId
        self.state = state
        self.audience = audience
        self.nonce = nonce
        self.configuration = libraryConfiguration
        self.idTokenBuilder = PresentationExchangeIdTokenBuilder()
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
            let partialInputDescriptor = PartialInputDescriptor(rawVC: rawVC,
                                                                peRequirement: peRequirement)
            addToVPGroupings(partialInputDescriptor: partialInputDescriptor)
        }
    }
    
    private func addToVPGroupings(partialInputDescriptor: PartialInputDescriptor)
    {
        for group in vpBuilders
        {
            if group.canInclude(partialInputDescriptor: partialInputDescriptor)
            {
                group.add(partialInputDescriptor: partialInputDescriptor)
                return
            }
        }
        
        let newBuilder = VerifiablePresentationBuilder(index: vpBuilders.count)
        newBuilder.add(partialInputDescriptor: partialInputDescriptor)
        vpBuilders.append(newBuilder)
    }
    
    func build() throws -> PresentationResponse
    {
        let identifier = try configuration.identifierManager.fetchOrCreateMasterIdentifier()
        
        guard let firstKey = identifier.didDocumentKeys.first else
        {
            throw IdentifierError.NoKeysInDocument()
        }
        
        let idToken = try buildIdToken(identifier: identifier.longFormDid,
                                       signingKey: firstKey)
        let vpTokens = try buildVpTokens(identifier: identifier.longFormDid,
                                         signingKey: firstKey)
        return PresentationResponse(idToken: idToken,
                                    vpTokens: vpTokens,
                                    state: state)
    }
    
    private func buildIdToken(identifier: String, signingKey: KeyContainer) throws -> PresentationResponseToken
    {
        let inputDescriptors = vpBuilders.flatMap { $0.buildInputDescriptors() }
        return try idTokenBuilder.build(inputDescriptors: inputDescriptors,
                                        definitionId: definitionId,
                                        audience: audience,
                                        nonce: nonce,
                                        identifier: identifier,
                                        signingKey: signingKey)
    }
    
    private func buildVpTokens(identifier: String,
                               signingKey: KeyContainer) throws -> [VerifiablePresentation]
    {
        return try vpBuilders.map { builder in
            return try builder.buildVerifiablePresentation(audience: audience,
                                                           nonce: nonce,
                                                           identifier: identifier,
                                                           signingKey: signingKey)
        }
    }
}
