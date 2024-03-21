/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Raw OpenID4VCI Request Data Model to send to the Issuance Service from Wallet.
 */
struct RawOpenID4VCIRequest: Encodable
{
    /// Describes the credential to be issued.
    let credential_configuration_id: String
    
    /// The issuer state from the credential offering.
    let issuer_session: String
    
    /// The proof needed to get the credential.
    let proof: OpenID4VCIJWTProof
}

/**
 * The proof needed to get the credential in JWT format.
 */
struct OpenID4VCIJWTProof: Encodable
{
    /// The format the proof is in.
    let proof_type: String = "jwt"
    
    /// The proof in JWT format.
    let jwt: String
}

/**
 * The claims in the token
 */
struct OpenID4VCIJWTProofClaims: Claims
{
    /// Identifies the recipients that the JWT is intended for.
    /// Should be equal to the credential endpoint.
    let aud: String
    
    /// Identifies the time at which the JWT was issued.
    let iat: Int
    
    /// Identifies the subject of the JWT.
    /// Should be equal to the user's DID.
    let sub: String
    
    /// Provides integrity protection for the access token.
    let at_hash: String
    
    init(credentialEndpoint: String,
         did: String,
         accessTokenHash: String)
    {
        self.aud = credentialEndpoint
        self.iat = Int(Date().timeIntervalSince1970)
        self.sub = did
        self.at_hash = accessTokenHash
    }
}
