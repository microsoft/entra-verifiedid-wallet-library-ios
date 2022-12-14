/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe a self attested claim required for a Verified Id issuance flow.
 */
public struct SelfAttestedClaimRequirement {
    
    /// If the requirement should be encrypted.
    let encrypted: Bool
    
    /// If the requirement is required or not.
    public let required: Bool
    
    /// The claim requested.
    public let claim: String
}

