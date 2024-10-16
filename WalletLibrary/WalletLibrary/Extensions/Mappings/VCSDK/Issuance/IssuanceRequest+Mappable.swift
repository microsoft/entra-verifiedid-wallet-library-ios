/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An extension of the VCEntities.IssuanceRequest class.
 */
extension IssuanceRequest: Mappable {
    func map(using mapper: Mapping) throws -> IssuanceRequestContent {
        
        let attestations = try getRequiredProperty(property: content.input.attestations,
                                                   propertyName: "attestations")
        let requirement = try mapper.map(attestations)
        let rootOfTrust = try mapper.map(linkedDomainResult)
        
        let issuerName = content.display.card.issuedBy
        let requestTitle = content.display.consent.title
        let requestInstruction = content.display.consent.instructions
        let issuerStyle = VerifiedIdManifestIssuerStyle(name: issuerName,
                                                        requestTitle: requestTitle,
                                                        requestInstructions: requestInstruction)
        let verifiedIdStyle = try mapper.map(content.display.card)
        
        return IssuanceRequestContent(style: issuerStyle,
                                      verifiedIdStyle: verifiedIdStyle,
                                      requirement: requirement,
                                      rootOfTrust: rootOfTrust)
    }
}
