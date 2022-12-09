/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe Verified IDs required.
 */
public struct VerifiedIdRequirement {
    /// id of the requirement.
    let id: String
    
    /// If requirement must be encrypted.
    let encrypted: Bool
    
    /// if the requirement is required or not.
    public let required: Bool
    
    /// the type of the verified Id required.
    public let types: [String]
    
    /// accepted issuers for verified Id required.
    public let acceptedIssuers: [String]
    
    /// the purpose for the verified Id, developer can display to the user if desired.
    public let purpose: String?
    
    /// optional property for info needed for issuance during presentation flow.
    public let credentialIssuanceParams: CredentialIssuanceParams?
    
    /// helper method that returns Verified Id that match the requirement from a list of Verified Ids.
    public func getMatches(verifiedIds: [VerifiedId]) -> [VerifiedId] {
        return []
    }
}
