/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * Errors thrown in Pin Descriptor Mappable extension.
 */
enum PinDescriptorError: Error {
    case presentationDefinitionMissingInRequest
}

/**
 * An extension of the VCEntities.PinDescriptor class to be able
 * to map PinDescriptor to PinRequirement.
 */
extension VCEntities.PinDescriptor: Mappable {
    
    func map(using mapper: Mapping) throws -> PinRequirement {
        
        let type = try getRequiredProperty(property: type, propertyName: "type")
        
        let pinRequirement = PinRequirement(required: true,
                                            length: length,
                                            type: type,
                                            salt: salt)
        return pinRequirement
    }
}
