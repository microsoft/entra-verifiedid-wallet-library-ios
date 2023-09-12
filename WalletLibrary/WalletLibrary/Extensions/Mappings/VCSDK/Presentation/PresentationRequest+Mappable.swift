/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

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
        
        guard let claims = content.claims else {
            throw PresentationRequestMappingError.presentationDefinitionMissingInRequest
        }
        
        let requestState = try self.getRequiredProperty(property: content.state, propertyName: "state")
        let redirectUri = try self.getRequiredProperty(property: content.redirectURI, propertyName: "redirectUri")
        
        guard let callbackUrl = URL(string: redirectUri) else {
            throw PresentationRequestMappingError.callbackURLMalformed(content.redirectURI)
        }
        
        let requirement = try mapper.map(claims)
        let rootOfTrust = try mapper.map(linkedDomainResult)
        let injectedIdToken = try createInjectedIdTokenIfExists(using: mapper)
        
        let clientName = content.registration?.clientName ?? ""
        
        var logo: VerifiedIdLogo? = nil
        if let logoUri = content.registration?.logoURI,
           let logoURL = URL(string: logoUri) {
            logo = VerifiedIdLogo(url: logoURL, altText: nil)
        }

        let requesterStyle = OpenIdVerifierStyle(name: clientName, logo: logo)
        
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
