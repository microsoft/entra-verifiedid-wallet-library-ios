/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe a self attested claim required for a Verified Id issuance flow.
 */
public class SelfAttestedClaimRequirement: Requirement {
    
    /// If the requirement should be encrypted.
    let encrypted: Bool
    
    /// If the requirement is required or not.
    public let required: Bool
    
    /// The claim requested.
    public let claim: String
    
    init(encrypted: Bool, required: Bool, claim: String) {
        self.encrypted = encrypted
        self.required = required
        self.claim = claim
    }
    
    public func validate() throws {
        throw VerifiedIdClientError.TODO(message: "implement validate")
    }
}
