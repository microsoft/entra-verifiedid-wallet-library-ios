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
    let credential_identifier: String
    
    let format: String = "jwt_vc_json"
    
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

struct OpenID4VCIJWTProofClaims: Claims
{
    let aud: String
    
    let credential_identifier: String
    
    let iat: String
    
    let sub: String
    
    let at_hash: String
    
    init(credentialIssuer: String,
         credentialConfigurationId: String,
         did: String,
         accessTokenHash: String)
    {
        self.aud = credentialIssuer
        self.credential_identifier = credentialConfigurationId
        self.iat = String(Int(Date().timeIntervalSince1970))
        self.sub = did
        self.at_hash = accessTokenHash
    }
}
