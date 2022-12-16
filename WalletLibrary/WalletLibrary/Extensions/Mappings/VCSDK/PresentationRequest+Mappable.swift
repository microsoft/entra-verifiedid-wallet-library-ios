/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.PresentationRequest class to be able
 * to map VCEntities.PresentationRequest to Request.
 */
extension VCEntities.PresentationRequest: Mappable {
    
    func map(using mapper: Mapping) throws -> Request {
        
        let credentialIssuerMetadata = getCredentialIssuerMetadata()
        let pinRequirements = try getPinRequirement()
        
        let clientId = try getRequiredProperty(property: content.clientID, propertyName: "content.clientID")
        let state = try getRequiredProperty(property: content.state, propertyName: "state")
        let raw = try getRequiredProperty(property: token.rawValue, propertyName: "token.rawValue")
        
        return IssuanceRequest(requester: clientId,
                               credentialIssuerMetadata: credentialIssuerMetadata,
                               contracts: [],
                               pinRequirements: pinRequirements,
                               credentialFormats: nil, // Value is nil for current issuance flow
                               state: state,
                               raw: raw)
    }
    
    private func getCredentialIssuerMetadata() -> [String] {
        guard let contractUrl = self.content.claims?.vpToken?.presentationDefinition?.inputDescriptors?.first?.issuanceMetadata?.first?.contract else {
            return []
        }
        return [contractUrl]
    }
    
    private func getPinRequirement() throws -> PinRequirement? {
        
        guard let pinRequirements = self.content.idTokenHint?.token.content.pin else {
            return nil
        }
        
        let type = try getRequiredProperty(property: pinRequirements.type, propertyName: "pinRequirements.type")
        
        return PinRequirement(length: pinRequirements.length, type: type)
    }
    
    
}
