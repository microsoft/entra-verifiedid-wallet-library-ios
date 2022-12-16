/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An Extension of the VCEntities.IssuanceRequest class to be able
 * to map VCEntities.IssuanceRequest to Contract.
 */
extension VCEntities.IssuanceRequest: Mappable {
    
    func map(using mapper: Mapping) throws -> Contract {
        
        let raw = try getRequiredProperty(property: token.rawValue,
                                          propertyName: "token.rawValue")
        let requirements = try getRequiredProperty(property: content.input.attestations,
                                                   propertyName: "content.input.attestations")
        
        let rootOfTrust = getRootOfTrust()
        
        let verifiedIdRequirements = try requirements.presentations?.compactMap {
            try mapper.map($0)
        } ?? []
        
        let idTokenRequirements = try requirements.idTokens?.compactMap {
            try mapper.map($0)
        } ?? []
        
        let accessTokenRequirements = try requirements.accessTokens?.compactMap {
            try mapper.map($0)
        } ?? []
        
        var selfAttestedClaimRequirements: [SelfAttestedClaimRequirement] = []
        if let selfIssued = requirements.selfIssued {
            selfAttestedClaimRequirements = try mapper.map(selfIssued)
        }
        
        return Contract(rootOfTrust: rootOfTrust,
                        verifiedIdRequirements: verifiedIdRequirements,
                        idTokenRequirements: idTokenRequirements,
                        accessTokenRequirements: accessTokenRequirements,
                        selfAttestedClaimRequirements: selfAttestedClaimRequirements,
                        raw: raw)
    }
    
    private func getRootOfTrust() -> RootOfTrust {
        
        switch linkedDomainResult {
        case .linkedDomainMissing:
            return RootOfTrust(verified: false, source: nil)
        case .linkedDomainUnverified(let domainUrl):
            return RootOfTrust(verified: false, source: domainUrl)
        case .linkedDomainVerified(let domainUrl):
            return RootOfTrust(verified: true, source: domainUrl)
        }
    }
}
    
