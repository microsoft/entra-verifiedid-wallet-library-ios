/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

/**
 * Errors thrown in Presentation Request Mappable extension.
 */
enum PresentationRequestMappingError: Error, Equatable {
    case presentationDefinitionMissingInRequest
    case callbackURLMalformed(String?)
}

/**
 * An extension of the VCEntities.PresentationRequest class to be able
 * to map PresentationRequest to VerifiedIdRequestContent.
 */
extension PresentationRequest: Mappable {
    
    func map(using mapper: Mapping) throws -> PresentationRequestContent {
        
        guard let presentationDefinition = content.claims?.vpToken?.presentationDefinition else {
            throw PresentationRequestMappingError.presentationDefinitionMissingInRequest
        }
        
        guard let redirectUri = content.redirectURI,
              let callbackUrl = URL(string: redirectUri) else {
            throw PresentationRequestMappingError.callbackURLMalformed(content.redirectURI)
        }
        
        let requestState = try self.getRequiredProperty(property: content.state, propertyName: "state")
        
        let requirement = try mapper.map(presentationDefinition)
        let rootOfTrust = try mapper.map(linkedDomainResult)
        let injectedIdToken = try createInjectedIdTokenIfExists(using: mapper)
        
        let clientName = content.registration?.clientName ?? ""
        let requesterStyle = OpenIdVerifierStyle(name: clientName)
        
        let content = PresentationRequestContent(style: requesterStyle,
                                                 requirement: requirement,
                                                 rootOfTrust: rootOfTrust,
                                                 requestState: requestState,
                                                 callbackUrl: callbackUrl,
                                                 injectedIdToken: injectedIdToken)
        
        return content
    }
    
    private func createInjectedIdTokenIfExists(using mapper: Mapping) throws -> InjectedIdToken? {
        if let idTokenHint = content.idTokenHint {
            return InjectedIdToken(rawToken: idTokenHint,
                                   pin: try createPinRequirementIfExists(using: mapper))
        }
        
        return nil
    }
    
    private func createPinRequirementIfExists(using mapper: Mapping) throws -> PinRequirement? {
        if let pin = content.pin {
            return try mapper.map(pin)
        }
        
        return nil
    }
}
