/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A contract that contains the information needed to get a Verified Id
 * including display information through the trait properties.
 * TODO: Add display information properties once we have agreed on design.
 */
public struct Contract {

    /// Root of Trust such as Linked Domain Verified for the request.
    public let rootOfTrust: RootOfTrust
    
    /// information to describe Verified IDs required for issuance.
    public let verifiedIdRequirements: [VerifiedIdRequirement]

    /// information to describe id tokens required for issuance.
    public let idTokenRequirements: [IdTokenRequirement]

    /// information to describe access tokens required for issuance.
    public let accessTokenRequirements: [AccessTokenRequirement]

    /// information to describe self-attested required for issuance.
    public let selfAttestedClaimRequirements: SelfAttestedClaimRequirements?

    /// raw representation of the contract.
    let raw: String
}
