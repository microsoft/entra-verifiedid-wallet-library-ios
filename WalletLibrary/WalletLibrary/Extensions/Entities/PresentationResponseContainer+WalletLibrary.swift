/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

enum PresentationResponseContainerError: Error, Equatable {
    case unableToCastVCSDKPresentationRequestFromRawRequestOfType(String)
    case unsupportedRequirementOfType(String)
    case unableToCastVerifableCredentialFromVerifiedId
    case missingIdInVerifiedIdRequirement
}

/**
 * An extension of the VCEntities.PresentationResponseContainer class
 * to convert Requirements to mappings in PresentationResponseContainer.
 */
extension PresentationResponseContainer: RawPresentationResponse {

    init(rawRequest: any OpenIdRawRequest) throws {

        guard let presentationRequest = rawRequest as? PresentationRequest else {
            let requestType = String(describing: type(of: rawRequest))
            throw PresentationResponseContainerError.unableToCastVCSDKPresentationRequestFromRawRequestOfType(requestType)
        }

        try self.init(from: presentationRequest)
    }

    mutating func add(requirement: Requirement) throws {
        switch (requirement) {
        case let groupRequirement as GroupRequirement:
            try add(groupRequirement: groupRequirement)
        case let verifiedIdRequirement as VerifiedIdRequirement:
            try add(verifiedIdRequirement: verifiedIdRequirement)
        default:
            let requirementType = String(describing: type(of: requirement))
            throw PresentationResponseContainerError.unsupportedRequirementOfType(requirementType)
        }
    }

    private mutating func add(groupRequirement: GroupRequirement) throws {
        try groupRequirement.validate().get()
        for requirement in groupRequirement.requirements {
            try add(requirement: requirement)
        }
    }

    private mutating func add(verifiedIdRequirement: VerifiedIdRequirement) throws {
        
        guard let requirementId = verifiedIdRequirement.id else {
            throw PresentationResponseContainerError.missingIdInVerifiedIdRequirement
        }
        
        guard let verifiableCredential = verifiedIdRequirement.selectedVerifiedId as? VCVerifiedId else {
            throw PresentationResponseContainerError.unableToCastVerifableCredentialFromVerifiedId
        }
        
        let mapping = RequestedVerifiableCredentialMapping(id: requirementId,
                                                           verifiableCredential: verifiableCredential.raw)
        self.requestVCMap.append(mapping)
    }
}
