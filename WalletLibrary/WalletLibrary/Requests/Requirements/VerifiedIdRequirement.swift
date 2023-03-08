/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe Verified IDs required.
 */
public class VerifiedIdRequirement: Requirement {
    
    /// If requirement must be encrypted.
    let encrypted: Bool
    
    /// Input descriptor id from the presentation request tied to verifiable credential requested.
    let id: String?
    
    /// If the requirement is required or not.
    public let required: Bool
    
    /// The types of the verified Id required.
    public let types: [String]
    
    /// The purpose for the verified Id, developer can display to the user if desired.
    public let purpose: String?
    
    /// An optional property for information needed for issuance during presentation flow.
    public let issuanceOptions: [VerifiedIdRequestInput]
    
    /// The verified id that fulfills the requirement.
    var selectedVerifiedId: VerifiedId?
    
    init(id: String? = nil,
         encrypted: Bool,
         required: Bool,
         types: [String],
         purpose: String?,
         issuanceOptions: [VerifiedIdRequestInput]) {
        self.id = id
        self.encrypted = encrypted
        self.required = required
        self.types = types
        self.purpose = purpose
        self.issuanceOptions = issuanceOptions
    }
    
    /// TODO: helper method that returns verified id that match the requirement from a list of verified ids.
    public func getMatches(verifiedIds: [VerifiedId]) -> [VerifiedId] {
        return []
    }
    
    /// Fulfill requirement with a verified id.
    /// TODO: do some validation to make sure verified id actually fulfills.
    public func fulfill(with verifiedId: VerifiedId) {
        selectedVerifiedId = verifiedId
    }
    
    public func validate() throws {
        throw VerifiedIdClientError.TODO(message: "implement validate")
    }
}
