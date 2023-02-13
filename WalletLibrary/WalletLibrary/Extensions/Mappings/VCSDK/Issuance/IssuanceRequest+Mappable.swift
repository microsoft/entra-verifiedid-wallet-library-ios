/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.Contract class
 * to map Contract to VerifiedIdRequestContent.
 */
extension VCEntities.IssuanceRequest: Mappable {
    
    func map(using mapper: Mapping) throws -> VerifiedIdRequestContent {
        
        let requesterStyle = OpenIdVerifierStyle(name: "test")
        
        guard let attestations = content.input.attestations else {
            throw VerifiedIdClientError.TODO(message: "implement")
        }
        
        let issuerStyle = try mapper.map(self.content.display.consent)
        let requirement = try mapper.map(attestations)
        let rootOfTrust = try mapper.map(self.linkedDomainResult)
        
        let content = VerifiedIdRequestContent(style: issuerStyle,
                                               requirement: requirement,
                                               rootOfTrust: rootOfTrust)
        
        return content
    }
}
