/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Errors thrown in Presentation Definition Mappable extension.
 */
enum PresentationDefinitionMappingError: Error {
    case missingInputDescriptors
    case malformedPresentationRequest
}

/**
 * An extension of the VCEntities.PresentationDefinition class to be able
 * to map PresentationDefinition to Requirements.
 */
extension PresentationDefinition: Mappable {
    
    func map(using mapper: Mapping) throws -> [Requirement] {
        
        guard let inputDescriptors = self.inputDescriptors,
              !inputDescriptors.isEmpty else {
            throw PresentationDefinitionMappingError.missingInputDescriptors
        }
        
        if inputDescriptors.count == 1,
           let onlyPresentationInputDescriptor = inputDescriptors.first {
            return [try mapper.map(onlyPresentationInputDescriptor)]
        }
        
        let requirements = try inputDescriptors.compactMap {
            try mapper.map($0)
        }

        /// VC SDK only supports ALL operator for now.
        return requirements
    }
}
