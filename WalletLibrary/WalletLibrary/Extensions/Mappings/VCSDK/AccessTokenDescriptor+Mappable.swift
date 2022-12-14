/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An Extension of the VCEntities.AccessTokenDescriptor class to be able
 * to map AccessTokenDescriptor to AccessTokenRequirement.
 */
extension VCEntities.AccessTokenDescriptor: Mappable {
    
    typealias T = AccessTokenRequirement
    
    func map(using mapper: Mapping) throws -> AccessTokenRequirement {
        
        let configuration = try getRequiredProperty(property: configuration, propertyName: "configuration")
        let resourceId = try getRequiredProperty(property: resourceId, propertyName: "resourceId")
        let scope = try getRequiredProperty(property: oboScope, propertyName: "oboScope")

        return AccessTokenRequirement(encrypted: encrypted ?? false,
                                      required: self.required ?? false,
                                      configuration: configuration,
                                      clientId: nil,
                                      resourceId: resourceId,
                                      scope: scope)
    }
    
}
