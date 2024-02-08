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

/**
 * Defines a typealias `SignedMetadata` that represents a JWS Token with claims specific to signed metadata.
 */
typealias SignedMetadata = JwsToken<SignedMetadataTokenClaims>

/**
 * This structure is designed to hold claims related to signed metadata tokens.
 */
struct SignedMetadataTokenClaims: Claims
{
    let sub: String?
    
    let iss: String?
}

/**
 * Extends `SignedMetadata` with functionality for validating the claims contained within the token.
 */
extension SignedMetadata
{
    /// Validates the claims of the signed metadata token against expected values.
    func validateClaims(expectedSubject: String,
                        expectedIssuer: String) throws
    {
        if expectedIssuer != content.iss
        {
            throw TokenValidationError.InvalidProperty(content.iss, expected: expectedIssuer)
        }
        
        if expectedSubject != content.sub
        {
            throw TokenValidationError.InvalidProperty(content.sub, expected: expectedSubject)
        }
        
        try validateIatAndExp()
    }
}
