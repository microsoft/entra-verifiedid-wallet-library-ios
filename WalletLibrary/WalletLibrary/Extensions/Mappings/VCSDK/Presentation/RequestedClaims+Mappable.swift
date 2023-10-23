/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An extension of the VCEntities.RequestedClaims class to be able
 * to map RequestedClaims to a Requirement.
 */
extension RequestedClaims: Mappable
{
    
    func map(using mapper: Mapping) throws -> Requirement
    {
        var requirements: [Requirement] = []
        
        if let presentationDefinition = vpToken.presentationDefinition
        {
            requirements.append(contentsOf: try mapper.map(presentationDefinition))
        }
        
        if requirements.isEmpty
        {
            throw PresentationDefinitionMappingError.malformedPresentationRequest
        }
        
        if requirements.count == 1,
           let onlyRequirement = requirements.first
        {
            return onlyRequirement
        }
        
        return GroupRequirement(required: true,
                                requirements: requirements,
                                requirementOperator: .ALL)
    }
}
