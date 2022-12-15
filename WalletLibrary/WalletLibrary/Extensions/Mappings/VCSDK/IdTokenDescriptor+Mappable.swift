/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.IdTokenDescriptor class to be able
 * to map IdTokenDescriptor to IdTokenRequirement.
 */
extension VCEntities.IdTokenDescriptor: Mappable {
    
    /// Map the id token descriptor to the id token requirement.
    func map(using mapper: Mapping) throws -> IdTokenRequirement {
        
        guard let configuration = URL(string: configuration) else {
            throw MappingError.InvalidProperty(property:"configuration",
                                               in: String(describing: IdTokenDescriptor.self))
        }
        
        let redirectUri = try getRequiredProperty(property: redirectURI, propertyName: "redirectURI")
        let scope = try getRequiredProperty(property: scope, propertyName: "scope")

        return IdTokenRequirement(encrypted: encrypted ?? false,
                                  required: idTokenRequired ?? false,
                                  configuration: configuration,
                                  clientId: clientID,
                                  redirectUri: redirectUri,
                                  scope: scope,
                                  nonce: nil)
    }
    
}
