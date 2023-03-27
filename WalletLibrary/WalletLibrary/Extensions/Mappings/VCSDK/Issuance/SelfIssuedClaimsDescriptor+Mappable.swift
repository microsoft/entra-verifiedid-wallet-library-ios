/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

/**
 * An extension of the VCEntities.SelfIssuedClaimsDescriptor class to be able
 * to map SelfIssuedClaimsDescriptor to Requirement.
 */
extension SelfIssuedClaimsDescriptor: Mappable {
    
    func map(using mapper: Mapping) throws -> Requirement? {
        
        guard let claims = claims, !claims.isEmpty else {
            return nil
        }
        
        let areSelfAttestedClaimsRequired = selfIssuedRequired ?? false
        
        if claims.count == 1,
           let onlyClaim = claims.first {
            
            let isIndividualClaimRequired = onlyClaim.claimRequired ?? false
            let required = areSelfAttestedClaimsRequired || isIndividualClaimRequired
            return SelfAttestedClaimRequirement(encrypted: encrypted ?? false,
                                                required: required,
                                                claim: onlyClaim.claim)
        }
        
        let requirements = claims.compactMap { claim in
            
            let isIndividualClaimRequired = claim.claimRequired ?? false
            return SelfAttestedClaimRequirement(encrypted: encrypted ?? false,
                                                required: isIndividualClaimRequired,
                                                claim: claim.claim)
        }
        
        return GroupRequirement(required: areSelfAttestedClaimsRequired,
                                requirements: requirements,
                                requirementOperator: .ALL)
    }
}
