/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe a self attested claims required for a Verified Id issuance flow.
 */
public struct SelfAttestedClaimRequirements: Equatable {
    
    /// If the requirement should be encrypted.
    public let encrypted: Bool
    
    /// If the requirement is required or not.
    public let required: Bool
    
    /// The claims required.
    public let requiredClaims: [SelfAttestedClaimRequirement]
}

