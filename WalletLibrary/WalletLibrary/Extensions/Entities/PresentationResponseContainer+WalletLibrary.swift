/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

enum PresentationResponseError: Error, Equatable {
    case unableToCastVCSDKPresentationRequestFromRawRequestOfType(String)
    case unsupportedRequirementOfType(String)
    case unableToCastVerifableCredentialFromVerifiedIdOfType(String)
    case missingIdInVerifiedIdRequirement
}

/**
 * An extension of the VCEntities.PresentationResponseContainer class
 * to convert Requirements to mappings in PresentationResponseContainer.
 */
extension VCEntities.PresentationResponseContainer: PresentationResponse {

    init(from request: any OpenIdRawRequest) throws {

        guard let request = request as? PresentationRequest else {
            let requestType = String(describing: type(of: request))
            throw PresentationResponseError.unableToCastVCSDKPresentationRequestFromRawRequestOfType(requestType)
        }

        try self.init(from: request)
    }

    mutating func add(requirement: Requirement) throws {
        switch (requirement) {
        case let groupRequirement as GroupRequirement:
            try add(groupRequirement: groupRequirement)
        case let verifiedIdRequirement as VerifiedIdRequirement:
            try add(verifiedIdRequirement: verifiedIdRequirement)
        default:
            let requirementType = String(describing: type(of: requirement))
            throw PresentationResponseError.unsupportedRequirementOfType(requirementType)
        }
    }

    private mutating func add(groupRequirement: GroupRequirement) throws {
        try groupRequirement.validate()
        for requirement in groupRequirement.requirements {
            try add(requirement: requirement)
        }
    }

    private mutating func add(verifiedIdRequirement: VerifiedIdRequirement) throws {
        throw VerifiedIdClientError.TODO(message: "Implement in next PR.")
    }
}
