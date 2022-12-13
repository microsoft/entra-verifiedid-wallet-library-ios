/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe a self attested claim required for a Verified Id issuance flow.
 */
public struct SelfAttestedClaimRequirement {
    /// id of the requirement.
    let id: String
    
    /// if the requirement should be encrypted.
    let encrypted: Bool
    
    /// if the requirement is required or not.
    public let required: Bool
    
    /// the claim requested.
    public let claim: String
}

