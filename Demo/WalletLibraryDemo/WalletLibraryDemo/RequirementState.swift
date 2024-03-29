/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import WalletLibrary

enum RequirementStateError: String, Error {
    case unsupportedRequirementType = "Unsupported Requirement Type"
    case invalidInputToFulfillRequirement = "Invalid Input to Fulfill Requirement"
    case requirementIsNotOfTypeVerifiedIdRequirement = "Requirement cannot be fulfilled by Verified Id"
}

/// Requirement Status based on whether requirement is valid or missing.
enum RequirementStatus {
    case missing
    case valid
    case invalid
}

class RequirementState: Identifiable, ObservableObject {
    
    @Published var label: String
    
    @Published var status: RequirementStatus
    
    let requirement: Requirement
    
    let id = UUID()
    
    init(label: String,
         status: RequirementStatus,
         requirement: Requirement) {
        self.label = label
        self.status = status
        self.requirement = requirement
    }
    
    init(requirement: Requirement) throws {
        self.requirement = requirement
        self.status = .missing
        switch (requirement) {
        case let selfAttestedClaimRequirement as SelfAttestedClaimRequirement:
            self.label = "Add User Input for \(selfAttestedClaimRequirement.claim)"
        case is PinRequirement:
            self.label = "Add Pin"
        case let idTokenRequirement as IdTokenRequirement:
            self.label = "Id Token for: \(idTokenRequirement.configuration)"
            try? addNewLabelIfValid(newLabel: "Valid Id Token Present")
        case let verifiedIdRequirement as VerifiedIdRequirement:
            self.label = "Verified Id Requirement for types: \(verifiedIdRequirement.types)"
        default:
            throw RequirementStateError.unsupportedRequirementType
        }
    }
    
    func fulfill(with value: String) throws {
        switch (requirement) {
        case let selfAttestedClaimRequirement as SelfAttestedClaimRequirement:
            selfAttestedClaimRequirement.fulfill(with: value)
            try addNewLabelIfValid(newLabel: "User Input: \(value)")
        case let pinRequirement as PinRequirement:
            pinRequirement.fulfill(with: value)
            try addNewLabelIfValid(newLabel: "Pin Input: \(value)")
        default:
            throw RequirementStateError.unsupportedRequirementType
        }
    }
    
    func fulfill(with value: VerifiedId) throws {
        
        guard let verifiedIdRequirement = requirement as? VerifiedIdRequirement else {
            throw RequirementStateError.requirementIsNotOfTypeVerifiedIdRequirement
        }
        
        let _ = verifiedIdRequirement.fulfill(with: value)
        try addNewLabelIfValid(newLabel: "Verified Id Requirement Fulfilled.")
    }
    
    private func addNewLabelIfValid(newLabel: String) throws {
        do {
            try requirement.validate().get()
            label = newLabel
            status = .valid
        } catch {
            status = .invalid
            throw RequirementStateError.invalidInputToFulfillRequirement
        }
    }
}
