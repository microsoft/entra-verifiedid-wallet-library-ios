/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.IssuanceRequest class.
 * TODO: Update Style to include VerifiedIdStyle and more requester style attributes.
 */
extension VCEntities.IssuanceRequest: RawRequest, Mappable {
    func map(using mapper: Mapping) throws -> IssuanceRequestContent {
        
        let attestations = try getRequiredProperty(property: content.input.attestations,
                                                   propertyName: "attestations")
        let requirement = try mapper.map(attestations)
        let rootOfTrust = try mapper.map(linkedDomainResult)
        let issuerStyle = Manifest2022IssuerStyle(name: content.display.card.issuedBy)
        
        return IssuanceRequestContent(style: issuerStyle,
                                      requirement: requirement,
                                      rootOfTrust: rootOfTrust)
    }
}
