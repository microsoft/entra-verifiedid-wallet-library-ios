/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Handles serialization of Verified IDs from requirements and
 * builds a Presentation Response according to the OpenID Presentation Exchange specification
 */
class PresentationExchangeSerializer: RequestProcessorSerializing
{
    private let configuration: LibraryConfiguration
    
    /// A collection of builders for creating verifiable presentations.
    private var vpBuilders: [any VerifiablePresentationBuilding]
    
    /// A builder for creating the ID token part of the presentation exchange response.
    private let idTokenBuilder: any PresentationExchangeIdTokenBuilding
    
    /// Factory for creating token builders, facilitating the dynamic construction of presentation exchange components.
    private let tokenBuildFactory: TokenBuilderFactory
    
    /// State parameter from the original OpenID request, to be echoed back in the response.
    private let state: String
    
    /// Audience parameter indicating the intended recipient of the presentation exchange response.
    private let audience: String
    
    /// A nonce value to ensure from the request.
    private let nonce: String
    
    /// The Presentation Definition Id from the request.
    private let definitionId: String
    
    init(request: any OpenIdRawRequest,
         tokenBuilderFactory: TokenBuilderFactory = DefaultTokenBuilderFactory(),
         libraryConfiguration: LibraryConfiguration) throws
    {
        do
        {
            self.state = try request.getRequiredProperty(property: request.state,
                                                         propertyName: "state")
            self.audience = try request.getRequiredProperty(property: request.clientId,
                                                            propertyName: "client_id")
            self.nonce = try request.getRequiredProperty(property: request.nonce,
                                                         propertyName: "nonce")
            self.definitionId = try request.getRequiredProperty(property: request.definitionId,
                                                                propertyName: "definitionId")
            self.configuration = libraryConfiguration
            self.tokenBuildFactory = tokenBuilderFactory
            self.idTokenBuilder = tokenBuilderFactory.createPresentationExchangeIdTokenBuilder()
            self.vpBuilders = []
        }
        catch
        {
            throw PresentationExchangeError.MissingRequiredProperty(message: "Unable to create serializer.",
                                                                    error: error)
        }
    }
    
    /// Serializes a requirement into a partial input descriptor and adds it to the appropriate Verifiable Presentation builder.
    func serialize<T>(requirement: Requirement, verifiedIdSerializer: any VerifiedIdSerializing<T>) throws
    {
        let serializationResult = try requirement.serialize(protocolSerializer: self,
                                                            verifiedIdSerializer: verifiedIdSerializer)
        
        if let peRequirement = requirement as? PresentationExchangeRequirement,
           let rawVC = serializationResult as? String
        {
            let partialInputDescriptor = PartialInputDescriptor(serializedVerifiedId: rawVC,
                                                                requirement: peRequirement)
            addToVPGroupings(partialInputDescriptor: partialInputDescriptor)
        }
//        else
//        {
//            let message = "Verified ID serialized to incorrect type."
//            configuration.logger.logVerbose(message: message)
//        }
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
        
        let newBuilder = tokenBuildFactory.createVerifiablePresentationBuilder(index: vpBuilders.count)
        newBuilder.add(partialInputDescriptor: partialInputDescriptor)
        vpBuilders.append(newBuilder)
    }
    
    /// Builds the final presentation response which includes the ID token and Verifiable Presentations.
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
