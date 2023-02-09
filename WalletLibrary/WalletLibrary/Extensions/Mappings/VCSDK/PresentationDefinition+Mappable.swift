/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.PresentationDescriptor class to be able
 * to map PresentationDescriptor to VerifiedIdRequirement.
 */
extension VCEntities.PresentationDefinition: Mappable {
    
    func map(using mapper: Mapping) throws -> Requirement {
        
        guard let inputDescriptors = self.inputDescriptors else {
            throw VerifiedIdClientError.TODO(message: "add error")
        }
        
        if inputDescriptors.capacity == 1,
           let onlyDescriptor = inputDescriptors.first {
            return try mapper.map(onlyDescriptor)
        }
        
        let requirements = try inputDescriptors.compactMap {
            try mapper.map($0)
        }

        /// VC SDK only supports any operator for now.
        return GroupRequirement(required: true,
                                requirements: requirements,
                                requirementsOperator: .ANY)
    }
}
