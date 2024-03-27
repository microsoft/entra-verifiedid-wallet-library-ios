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
    
    private var vpBuilders: [any VerifiablePresentationBuilding]
    
    private let idTokenBuilder: any PresentationExchangeIdTokenBuilding
    
    private let tokenBuildFactory: TokenBuilderFactory
    
    private let state: String
    
    private let audience: String
    
    private let nonce: String
    
    private let definitionId: String
    
    init(request: any OpenIdRawRequest,
         tokenBuilderFactory: TokenBuilderFactory = PETokenBuilderFactory(),
         libraryConfiguration: LibraryConfiguration) throws
    {
        do
        {
            self.state = try request.getRequiredProperty(property: request.state,
                                                         propertyName: "state")
            self.audience = try request.getRequiredProperty(property: request.issuer,
                                                            propertyName: "issuer")
            self.nonce = try request.getRequiredProperty(property: request.nonce,
                                                         propertyName: "nonce")
            self.definitionId = try request.getRequiredProperty(property: request.definitionId,
                                                                propertyName: "definitionId")
            self.configuration = libraryConfiguration
            self.tokenBuildFactory = tokenBuilderFactory
            self.idTokenBuilder = tokenBuilderFactory.createPEIdTokenBuilder()
            self.vpBuilders = []
        }
        catch
        {
            throw RequestProcessorError.MissingRequiredProperty(message: "Unable to create serializer.",
                                                                error: error)
        }
    }
    
    func serialize<T>(requirement: Requirement, verifiedIdSerializer: any VerifiedIdSerializing<T>) throws
    {
        guard let peRequirement = requirement as? PresentationExchangeRequirement else
        {
            let message = "Unable to serialize requirement type: \(String(describing: requirement.self))"
            configuration.logger.logVerbose(message: message)
            return
        }
        
        if let rawVC = try requirement.serialize(protocolSerializer: self,
                                                 verifiedIdSerializer: verifiedIdSerializer) as? String
        {
            let partialInputDescriptor = PartialInputDescriptor(rawVC: rawVC,
                                                                peRequirement: peRequirement)
            addToVPGroupings(partialInputDescriptor: partialInputDescriptor)
        }
        else
        {
            let message = "Verified ID serialized to incorrect type."
            configuration.logger.logVerbose(message: message)
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
        
        let newBuilder = tokenBuildFactory.createVPTokenBuilder(index: vpBuilders.count)
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
