/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.IdTokenDescriptor class to be able
 * to map IdTokenDescriptor to IdTokenRequirement.
 */
extension VCEntities.LinkedDomainResult: Mappable {
    
    /// Map the id token descriptor to the id token requirement.
    func map(using mapper: Mapping) throws -> RootOfTrust {
        switch (self) {
        case LinkedDomainResult.linkedDomainMissing:
            return RootOfTrust(verified: false, source: nil)
        case LinkedDomainResult.linkedDomainUnverified(domainUrl: let source):
            return RootOfTrust(verified: false, source: source)
        case LinkedDomainResult.linkedDomainVerified(domainUrl: let source):
            return RootOfTrust(verified: true, source: source)
        }
    }
}
