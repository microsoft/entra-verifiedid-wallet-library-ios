/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

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
    
    func map(using mapper: Mapping) throws -> PresentationExchangeVerifiedIdRequirement {
        
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
        
        var constraints: [VerifiedIdConstraint] = []
        if let fields = self.constraints?.fields {
            for field in fields {
                do {
                    constraints.append(try mapper.map(field))
                } catch PresentationExchangeFieldConstraintError.InvalidPatternOnThePresentationExchangeField
                {
                    // Currently only face-check photo constraints can do this
                    // simply do not add the constraint
                }
            }
        }
        
        var verifiedIdConstraint = getTypeConstraint(from: types)
        if !constraints.isEmpty {
            constraints.append(verifiedIdConstraint)
            verifiedIdConstraint = GroupConstraint(constraints: constraints,
                                                   constraintOperator: .ALL)
        }
        
        // Fix exclusive presentation with.
        return PresentationExchangeVerifiedIdRequirement(encrypted: false,
                                                         required: true,
                                                         types: types,
                                                         purpose: purpose,
                                                         issuanceOptions: issuanceOptions ?? [],
                                                         id: id,
                                                         constraint: verifiedIdConstraint,
                                                         inputDescriptorId: id ?? "",
                                                         format: "jwt_vc",
                                                         exclusivePresentationWith: nil)
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

extension PresentationExchangeField: Mappable {
    
    func map(using mapper: Mapping) throws -> VerifiedIdConstraint {
        return try PresentationExchangeFieldConstraint(field: self)
    }
}
