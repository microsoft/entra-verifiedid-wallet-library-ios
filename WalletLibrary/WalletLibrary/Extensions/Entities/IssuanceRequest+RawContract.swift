/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.IssuanceRequest class.
 * TODO: Update Style to include VerifiedIdStyle and more requester style attributes.
 */
extension VCEntities.IssuanceRequest: RawContract {
    func map(using mapper: Mapping) throws -> VerifiedIdRequestContent {
        
        let attestations = try getRequiredProperty(property: content.input.attestations, propertyName: "Contract Attestations")
        let requirement = try mapper.map(attestations)
        let rootOfTrust = try mapper.map(linkedDomainResult)
        let issuerStyle = IssuerStyle(requester: content.display.card.issuedBy)
        
        return VerifiedIdRequestContent(style: issuerStyle,
                                        requirement: requirement,
                                        rootOfTrust: rootOfTrust)
    }
}

struct IssuerStyle: RequesterStyle {
    var requester: String
}
