/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Raw OpenID4VCI Well-Known Configuration Response Data Model received from the token endpoint.
 */
struct OpenIDWellKnownConfiguration: Decodable
{
    /// The issuer name.
    let issuer: String?
    
    /// The token endpoint URL.
    let token_endpoint: String?
    
    /// What Grant Types are supported.
    let grant_types_supported: [String]?
}
