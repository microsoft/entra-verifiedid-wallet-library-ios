/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdRequirementError: Error {
    case verifiedIdDoesNotMeetConstraints
    case requirementHasNotBeenFulfilled
}

/**
 * Information to describe Verified IDs required.
 */
public class VerifiedIdRequirement: Requirement {
    
    /// If requirement must be encrypted.
    let encrypted: Bool
    
    /// If the requirement is required or not.
    public let required: Bool
    
    /// The type of the verified Id required.
    public let types: [String]
    
    /// The purpose for the verified Id, developer can display to the user if desired.
    public let purpose: String?
    
    /// An optional property for information needed for issuance during presentation flow.
    public let issuanceOptions: [VerifiedIdRequestInput]
    
    /// Optional id of requirement defined by the request.
    let id: String?
    
    /// Constraint defines how the requirement can be fulfilled.
    let constraint: VerifiedIdConstraint
    
    /// The verified id that was selected.
    var selectedVerifiedId: VerifiedId?
    
    init(encrypted: Bool,
         required: Bool,
         types: [String],
         purpose: String?,
         issuanceOptions: [VerifiedIdRequestInput],
         id: String?,
         constraint: VerifiedIdConstraint) {
        self.encrypted = encrypted
        self.required = required
        self.types = types
        self.purpose = purpose
        self.issuanceOptions = issuanceOptions
        self.id = id
        self.constraint = constraint
    }
    
    public func validate() throws {
        guard let selectedVerifiedId = self.selectedVerifiedId else {
            throw VerifiedIdRequirementError.requirementHasNotBeenFulfilled
        }
        
        guard constraint.doesMatch(verifiedId: selectedVerifiedId) else {
            throw VerifiedIdRequirementError.verifiedIdDoesNotMeetConstraints
        }
    }
    
    public func getMatches(verifiedIds: [VerifiedId]) -> [VerifiedId] {
        return verifiedIds.filter {
            constraint.doesMatch(verifiedId: $0)
        }
    }
    
    public func fulfill(with verifiedId: VerifiedId) throws {
        
        guard constraint.doesMatch(verifiedId: verifiedId) else {
            throw VerifiedIdRequirementError.verifiedIdDoesNotMeetConstraints
        }
        
        self.selectedVerifiedId = verifiedId
    }
}
