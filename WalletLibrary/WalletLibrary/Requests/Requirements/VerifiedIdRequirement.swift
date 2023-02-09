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
    
    /// If the requirement is required or not.
    public let required: Bool
    
    /// The type of the verified Id required.
    public let types: [String]
    
    /// The accepted issuers for verified Id required.
    public let acceptedIssuers: [String]
    
    /// The purpose for the verified Id, developer can display to the user if desired.
    public let purpose: String?
    
    /// An optional property for information needed for issuance during presentation flow.
    public let issuanceOptions: [VerifiedIdIssuanceOption]
    
    /// TODO: helper method that returns verified id that match the requirement from a list of verified ids.
    public func getMatches(verifiedIds: [VerifiedId]) -> [VerifiedId] {
        return []
    }
    
    init(encrypted: Bool,
         required: Bool,
         types: [String],
         acceptedIssuers: [String],
         purpose: String?,
         issuanceOptions: [VerifiedIdIssuanceOption] = []) {
        self.encrypted = encrypted
        self.required = required
        self.types = types
        self.acceptedIssuers = acceptedIssuers
        self.purpose = purpose
        self.issuanceOptions = issuanceOptions
    }
    
    public func validate() throws {
        throw VerifiedIdClientError.TODO(message: "implement validate")
    }
}
