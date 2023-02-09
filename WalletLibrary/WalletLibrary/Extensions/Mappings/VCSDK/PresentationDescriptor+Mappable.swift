/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * An extension of the VCEntities.PresentationDescriptor class to be able
 * to map PresentationDescriptor to VerifiedIdRequirement.
 */
extension VCEntities.PresentationDescriptor: Mappable {
    
    func map(using mapper: Mapping) throws -> VerifiedIdRequirement {
        
        let acceptedIssuers = issuers?.compactMap { $0.iss } ?? []
        
        var issuanceOptions: [IssuanceOption] = []
        if let contracts = contracts,
           !contracts.isEmpty {
            issuanceOptions = contracts.compactMap {
                IssuanceOption(credentialIssuerMetadata: $0)
            }
        }
        
        return VerifiedIdRequirement(encrypted: encrypted ?? false,
                                     required: presentationRequired ?? false,
                                     types: [credentialType],
                                     acceptedIssuers: acceptedIssuers,
                                     purpose: nil,
                                     issuanceOptions: issuanceOptions)
    }
}
