/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.Contract class
 * to map Contract to VerifiedIdRequestContent.
 */
extension VCEntities.AttestationsDescriptor: Mappable {
    
    func map(using mapper: Mapping) throws -> Requirement {
        /// TODO implement
        return GroupRequirement(required: true,
                                requirements: [],
                                requirementOperator: .ANY)
    }
}
