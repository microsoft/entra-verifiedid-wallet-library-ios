/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

/**
 * Errors thrown in Presentation Input Descriptor Mappable extension.
 */
enum PresentationInputDescriptorMappingError: Error {
    case noVerifiedIdTypeInPresentationInputDescriptor
}

/**
 * An extension of the VCEntities.PresentationInputDescriptor class to be able
 * to map PresentationInputDescriptor to VerifiedIdRequirement.
 */
extension PresentationInputDescriptor: Mappable {
    
    func map(using mapper: Mapping) throws -> VerifiedIdRequirement {
        
        guard let types = schema?.compactMap({ $0.uri }),
              !types.isEmpty else {
            throw PresentationInputDescriptorMappingError.noVerifiedIdTypeInPresentationInputDescriptor
        }
        
        let issuanceOptions = self.issuanceMetadata?.compactMap {
            
            if let contract = $0.contract,
               let url = URL(string: contract) {
                return VerifiedIdRequestURL(url: url)
            }
            
            return nil
        }
        
        /// TODO: support presentation exchange constraints.
        let constraint = getTypeConstraint(from: types)
        
        return VerifiedIdRequirement(encrypted: false,
                                     required: true,
                                     types: types,
                                     purpose: purpose,
                                     issuanceOptions: issuanceOptions ?? [],
                                     id: id,
                                     constraint: constraint)
    }
    
    private func getTypeConstraint(from requestedTypes: [String]) -> VerifiedIdConstraint {
        
        if requestedTypes.count == 1, let onlyType = requestedTypes.first {
            return VCTypeConstraint(type: onlyType)
        }
        
        var typeConstraints: [VCTypeConstraint] = []
        for type in requestedTypes {
            typeConstraints.append(VCTypeConstraint(type: type))
        }
        
        /// TODO: Is this an ANY or ALL operation?
        return GroupConstraint(constraints: typeConstraints, constraintOperator: .ANY)
    }
}
