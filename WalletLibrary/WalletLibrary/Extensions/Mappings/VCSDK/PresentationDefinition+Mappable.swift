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
        throw VerifiedIdClientError.TODO(message: "implement")
    }
}
