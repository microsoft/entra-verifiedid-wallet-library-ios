/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Raw OpenID4VCI Response Data Model to received from the token endpoint.
 */
struct PreAuthTokenResponse: Decodable
{
    /// The access token.
    let access_token: String?
    
    /// The type of token received (ex. `bearer`).
    let token_type: String?
    
    /// When the token expires.
    let expires_in: String?
}
