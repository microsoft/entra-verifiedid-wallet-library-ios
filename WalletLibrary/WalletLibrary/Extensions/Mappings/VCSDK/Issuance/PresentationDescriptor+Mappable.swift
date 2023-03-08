/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.PresentationDescriptor class to be able
 * to map PresentationDescriptor to VerifiedIdRequirement.
 */
extension VCEntities.PresentationDescriptor: Mappable {
    
    func map(using mapper: Mapping) throws -> VerifiedIdRequirement {
        
        let issuanceOptions = contracts?.compactMap {
            
            if let contract = URL(string: $0) {
                return VerifiedIdRequestURL(url: contract)
            }
            
            return nil
        }
        
        /// VerifiedIdRequirements associated with issuance do not have an id.
        return VerifiedIdRequirement(id: nil,
                                     encrypted: encrypted ?? false,
                                     required: presentationRequired ?? false,
                                     types: [credentialType],
                                     purpose: nil,
                                     issuanceOptions: issuanceOptions ?? [])
    }
}
