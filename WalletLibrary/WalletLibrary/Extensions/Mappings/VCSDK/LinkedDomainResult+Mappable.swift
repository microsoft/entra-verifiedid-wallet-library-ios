/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

/**
 * An extension of the VCEntities.LinkedDomainResult class to be able
 * to map LinkedDomainResult to RootOfTrust.
 */
extension LinkedDomainResult: Mappable {
    
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
