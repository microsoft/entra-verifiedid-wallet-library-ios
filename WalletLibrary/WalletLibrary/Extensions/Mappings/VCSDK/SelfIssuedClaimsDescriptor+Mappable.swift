/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.SelfIssuedClaimsDescriptorclass to be able
 * to map VCEntities.SelfIssuedClaimsDescriptor to SelfAttestedClaimRequirements.
 */
extension VCEntities.SelfIssuedClaimsDescriptor: Mappable {
    
    func map(using mapper: Mapping) throws -> SelfAttestedClaimRequirements? {
        
        guard let claims = claims, !claims.isEmpty else {
            return nil
        }
        
        let claimRequirements = claims.compactMap { claimDescription in
            SelfAttestedClaimRequirement(required: claimDescription.claimRequired ?? false,
                                         claim: claimDescription.claim)
        }
        
        return SelfAttestedClaimRequirements(encrypted: encrypted ?? false,
                                             required: selfIssuedRequired ?? false,
                                             requiredClaims: claimRequirements)
    }
    
}
