/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe Verified IDs required.
 */
public struct VerifiedIdRequirement: Equatable {
    
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
    public let credentialIssuanceParams: CredentialIssuanceParams?
    
    /// TODO: helper method that returns verified id that match the requirement from a list of verified ids.
    public func getMatches(verifiedIds: [VerifiedId]) -> [VerifiedId] {
        return []
    }
}
