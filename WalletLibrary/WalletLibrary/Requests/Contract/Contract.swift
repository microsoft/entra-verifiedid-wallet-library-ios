/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A contract that contains the information needed to get a Verified Id
 * including display information through the trait properties.
 */
public struct Contract {
    
    /// the traits like name to describe the issuer.
    public let issuerTraits: RequesterTraits

    /// the traits such as background color and name to describe the verified id.
    public let verifiedIdTraits: VerifiedIdTraits

    /// information to describe Verified IDs required for issuance.
    public let verifiedIdRequirements: [VerifiedIdRequirement]

    /// information to describe id tokens required for issuance.
    public let idTokenRequirements: [IdTokenRequirement]

    /// information to describe access tokens required for issuance.
    public let accessTokenRequirements: [AccessTokenRequirement]

    /// information to describe self-attested required for issuance.
    public let selfAttestedClaimRequirements: [SelfAttestedClaimRequirement]

    /// raw representation of the contract.
    let raw: String
}

/// TODO: implement Requester Traits
public protocol RequesterTraits {}

/// TODO: implement VerifiedIdTraits
public protocol VerifiedIdTraits {}
