/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * Errors thrown in Presentation Definition Mappable extension.
 */
enum PresentationDefinitionMappingError: Error {
    case nilInputDescriptors
}

/**
 * An extension of the VCEntities.PresentationDefinition class to be able
 * to map PresentationDefinition to a Requirement.
 */
extension VCEntities.PresentationDefinition: Mappable {
    
    func map(using mapper: Mapping) throws -> Requirement {
        
        guard let inputDescriptors = self.inputDescriptors else {
            throw PresentationDefinitionMappingError.nilInputDescriptors
        }
        
        if inputDescriptors.capacity == 1,
           let onlyPresentationInputDescriptor = inputDescriptors.first {
            return try mapper.map(onlyPresentationInputDescriptor)
        }
        
        let requirements = try inputDescriptors.compactMap {
            try mapper.map($0)
        }

        /// VC SDK only supports ANY operator for now.
        return GroupRequirement(required: true,
                                requirements: requirements,
                                requirementOperator: .ANY)
    }
}
