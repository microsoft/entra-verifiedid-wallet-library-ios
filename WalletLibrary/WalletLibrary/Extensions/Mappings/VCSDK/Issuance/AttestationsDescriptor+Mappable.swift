/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.AttestationsDescriptor class to be able
 * to map AttestationsDescriptor to Requirement.
 */
extension VCEntities.AttestationsDescriptor: Mappable {
    
    /// Map the access token descriptor to access token requirement.
    func map(using mapper: Mapping) throws -> Requirement {
        let accessTokenRequirements: [Requirement] = try accessTokens?.compactMap { try mapper.map($0) } ?? []
        let idTokenRequirements: [Requirement] = try idTokens?.compactMap { try mapper.map($0) } ?? []
        let verifiedIdRequirements: [Requirement] = try presentations?.compactMap { try mapper.map($0) } ?? []
        
        let selfAttestedClaimRequirements: [Requirement] = selfIssued?.claims?.compactMap { claim in
            let isClaimRequired = claim.claimRequired ?? true
            return SelfAttestedClaimRequirement(encrypted: false, required: isClaimRequired, claim: claim.claim)
        } ?? []
        
        let requirements: [Requirement] = accessTokenRequirements + idTokenRequirements + verifiedIdRequirements + selfAttestedClaimRequirements
        
        if requirements.count == 1,
           let onlyRequirement = requirements.first {
            return onlyRequirement
        }
        
        return GroupRequirement(required: true,
                                requirements: requirements,
                                requirementOperator: .ALL)
    }
}
