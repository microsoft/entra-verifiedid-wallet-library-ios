/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * Errors thrown in Presentation Request Mappable extension.
 */
enum PresentationRequestMappingError: Error {
    case presentationDefinitionMissingInRequest
}

/**
 * An extension of the VCEntities.PresentationRequest class to be able
 * to map PresentationRequest to VerifiedIdRequestContent.
 */
extension VCEntities.PresentationRequest: Mappable {
    
    func map(using mapper: Mapping) throws -> VerifiedIdRequestContent {
        
        guard let presentationDefinition = content.claims?.vpToken?.presentationDefinition else {
            throw PresentationRequestMappingError.presentationDefinitionMissingInRequest
        }
        
        let requirement = try mapper.map(presentationDefinition)
        let rootOfTrust = try mapper.map(linkedDomainResult)
        let injectedIdToken = createInjectedIdTokenIfExists()
        
        let clientName = content.registration?.clientName ?? ""
        let requesterStyle = OpenIdVerifierStyle(name: clientName)
        
        let content = VerifiedIdRequestContent(style: requesterStyle,
                                               requirement: requirement,
                                               rootOfTrust: rootOfTrust,
                                               injectedIdToken: injectedIdToken)
        
        return content
    }
    
    private func createInjectedIdTokenIfExists() -> InjectedIdToken? {
        if let idTokenHint = content.idTokenHint {
            return InjectedIdToken(rawToken: idTokenHint,
                                              pin: createPinRequirementIfExists())
        }
        
        return nil
    }
    
    private func createPinRequirementIfExists() -> PinRequirement? {
        if let pin = content.pin,
           let type = pin.type {
            let pinRequirement = PinRequirement(required: true,
                                                length: pin.length,
                                                type: type,
                                                salt: pin.salt)
            return pinRequirement
        }
        
        return nil
    }
}

struct InjectedIdToken {
    let rawToken: String
    
    let pin: PinRequirement?
}
