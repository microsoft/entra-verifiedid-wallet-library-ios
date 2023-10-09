/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An extension of the VCEntities.PresentationDescriptor class to be able
 * to map PresentationDescriptor to VerifiedIdRequirement.
 */
extension PresentationDescriptor: Mappable {
    
    func map(using mapper: Mapping) throws -> VerifiedIdRequirement {
        
        let issuanceOptions = contracts?.compactMap {
            
            if let contract = URL(string: $0) {
                return VerifiedIdRequestURL(url: contract)
            }
            
            return nil
        }
        
        let constraint = VCTypeConstraint(type: credentialType)
        
        return VerifiedIdRequirement(encrypted: encrypted ?? false,
                                     required: presentationRequired ?? false,
                                     types: [credentialType],
                                     purpose: nil,
                                     issuanceOptions: issuanceOptions ?? [],
                                     id: credentialType,
                                     constraint: constraint)
    }
}
