/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An Extension of the VCEntities.SelfIssuedClaimsDescriptorclass to be able
 * to map VCEntities.SelfIssuedClaimsDescriptor to SelfAttestedClaimRequirements.
 */
extension VCEntities.SelfIssuedClaimsDescriptor: Mappable {
    typealias T = [SelfAttestedClaimRequirement]
    
    func map(using mapper: Mapping) throws -> [SelfAttestedClaimRequirement] {
        
        guard let claims = claims else {
            return []
        }
        
        return claims.compactMap { claimDescription in
            SelfAttestedClaimRequirement(encrypted: encrypted ?? false,
                                         required: claimDescription.claimRequired ?? false,
                                         claim: claimDescription.claim)
        }
    }
    
}
