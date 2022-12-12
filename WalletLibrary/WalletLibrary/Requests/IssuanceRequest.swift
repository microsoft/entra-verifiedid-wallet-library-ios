/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Issuance Request object containing information needed to get a Verified Id.
 */
public struct IssuanceRequest: Request {
    
    /// URL of the customer who is the issuer.
    public let requester: String
    
    /// Information such as a list of contract URLs to describe where to get contract.
    public let credentialIssuerMetadata: [String]
    
    /// A list of contracts that can be used to issue the verified id.
    public let contracts: [Contract]

    /// Optional pin requirements needed to display a pin for the request.
    public let pinRequirements: PinRequirement?

    /// Credential format data that describes requested verified id accepted formats.
    let credentialFormats: [CredentialFormat]

    /// the state that is sent back with issuance completion response.
    let state: String
}
