/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Credential Offer Data Model from the OpenID4VCI protocol.
 */
struct CredentialMetadata: Decodable
{
    /// The end point of the credential issuer.
    let credential_issuer: String?
    
    /// The authorization servers property is a list of endpoints that can be used to get access token for this issuer.
    let authorization_servers: [String]?
    
    /// The endpoint to send response to..
    let credential_endpoint: String?
    
    ///
    let notification_endpoint: String?
    
    /// A token to verify the issuer owns the DID and domain that the metadata comes from.
    let signed_metadata: String?
    
    /// A dictionary of Credential IDs to the corresponding contract.
    let credential_configurations_supported: [String: Any]?
    
    enum CodingKeys: String, CodingKey
    {
        case credential_issuer
        case authorization_servers
        case credential_endpoint
        case notification_endpoint
        case signed_metadata
        case credential_configurations_supported
    }
    
    init(from decoder: Decoder) throws 
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        credential_issuer = try container.decode(String.self, forKey: .credential_issuer)
        authorization_servers = try container.decode([String].self, forKey: .authorization_servers)
        credential_endpoint = try container.decode(String.self, forKey: .credential_endpoint)
        notification_endpoint = try container.decode(String.self, forKey: .notification_endpoint)
        signed_metadata = try container.decode(String.self, forKey: .signed_metadata)
        credential_configurations_supported = try container.decode(Dictionary<String, Any>.self,
                                                                   forKey: .credential_configurations_supported)
    }
}
