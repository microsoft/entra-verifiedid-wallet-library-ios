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
        
        var requirements: [Requirement] = []
        
        let accessTokenRequirements: [Requirement] = try accessTokens?.compactMap { try mapper.map($0) } ?? []
        requirements.append(contentsOf: accessTokenRequirements)
        
        let idTokenRequirements: [Requirement] = try idTokens?.compactMap { try mapper.map($0) } ?? []
        requirements.append(contentsOf: idTokenRequirements)
        
        let verifiedIdRequirements: [Requirement] = try presentations?.compactMap { try mapper.map($0) } ?? []
        requirements.append(contentsOf: verifiedIdRequirements)
        
        if let selfIssued = selfIssued,
           let selfAttestedClaimRequirements = try mapper.map(selfIssued) {
            requirements.append(selfAttestedClaimRequirements)
        }
        
        if requirements.count == 1,
           let onlyRequirement = requirements.first {
            return onlyRequirement
        }
        
        return GroupRequirement(required: true,
                                requirements: requirements,
                                requirementOperator: .ALL)
    }
}
