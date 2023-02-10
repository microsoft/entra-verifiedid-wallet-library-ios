/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

enum PresentationInputDescriptorMappingError: Error {
    case noVerifiedIdTypeInPresentationInputDescriptor
}

/**
 * An extension of the VCEntities.PresentationInputDescriptor class to be able
 * to map PresentationInputDescriptor to VerifiedIdRequirement.
 */
extension VCEntities.PresentationInputDescriptor: Mappable {
    
    func map(using mapper: Mapping) throws -> VerifiedIdRequirement {
        
        guard let types = schema?.compactMap({ $0.uri }),
              !types.isEmpty else {
            throw PresentationInputDescriptorMappingError.noVerifiedIdTypeInPresentationInputDescriptor
        }
        
        let issuanceOptions = self.issuanceMetadata?.compactMap {
            
            if let contract = $0.contract,
               let url = URL(string: contract) {
                return VerifiedIdRequestURL(url: url)
            }
            
            return nil
        }
        
        return VerifiedIdRequirement(encrypted: false,
                                     required: true,
                                     types: types,
                                     purpose: purpose,
                                     issuanceOptions: issuanceOptions ?? [])
    }
}
