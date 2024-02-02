/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Credential Offer Data Model from the OpenID4VCI protocol.
 */
struct CredentialOffer: Codable
{
    /// The end point of the credential issuer metadata.
    let credential_issuer: String?
    
    /// The state of the request. Opaque to the wallet.
    let issuer_session: String?
    
    /// The credential ids that will be used to issue the Verified ID.
    let credential_configuration_ids: [String]?
    
    /// An object indicating to the Wallet the Grant Types the Credential Issuer's AS is prepared to process for this Credential Offer.
    let grants: [String: CredentialOfferGrants]?
}

struct CredentialOfferGrants: Codable
{
    /**
     * A string that the Wallet can use to identify the Authorization Server to use with this grant type 
     * when authorization_servers parameter in the Credential Issuer metadata has multiple entries.
     * MUST NOT be used otherwise.
     * The value of this parameter MUST match with one of the values in the authorization_servers array obtained from the Credential Issuer metadata.
     */
    let authorization_server: String?
}
