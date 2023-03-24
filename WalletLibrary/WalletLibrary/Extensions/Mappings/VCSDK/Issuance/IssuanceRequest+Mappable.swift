/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

/**
 * An extension of the VCEntities.IssuanceRequest class.
 * TODO: Update Style to include VerifiedIdStyle and more requester style attributes.
 */
extension IssuanceRequest: Mappable {
    func map(using mapper: Mapping) throws -> IssuanceRequestContent {
        
        let attestations = try getRequiredProperty(property: content.input.attestations,
                                                   propertyName: "attestations")
        let requirement = try mapper.map(attestations)
        let rootOfTrust = try mapper.map(linkedDomainResult)
        let issuerStyle = VerifiedIdManifestIssuerStyle(name: content.display.card.issuedBy)
        let verifiedIdStyle = try mapper.map(content.display.card)
        
        return IssuanceRequestContent(style: issuerStyle,
                                      verifiedIdStyle: verifiedIdStyle,
                                      requirement: requirement,
                                      rootOfTrust: rootOfTrust)
    }
}
