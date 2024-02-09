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
    
    /// The endpoint to send response to.
    let credential_endpoint: String?
    
    /// The endpoint to send the result of the issuance back to.
    let notification_endpoint: String?
    
    /// A token to verify the issuer owns the DID and domain that the metadata comes from.
    let signed_metadata: String?
    
    /// A dictionary of Credential IDs to the corresponding credential configuration.
    let credential_configurations_supported: [String: CredentialConfiguration]?
}

extension CredentialMetadata
{
    func getCredentialConfigurations(ids: [String]) -> [CredentialConfiguration]
    {
        var configurations: [CredentialConfiguration] = []
        for id in ids
        {
            if let configuration = credential_configurations_supported?[id]
            {
                configurations.append(configuration)
            }
        }
        
        return configurations
    }
}
