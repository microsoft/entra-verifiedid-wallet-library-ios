/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Raw OpenID4VCI Pre Auth Token Request Data Model to send to token endpoint.
 */
struct PreAuthTokenRequest: PropertyIterable
{
    /// The type of request..
    /// Will always equal `urn:ietf:params:oauth:grant-type:pre-authorized_code`
    let grant_type: String
    
    /// The pre-authorized code found in the credential offer.
    let pre_authorized_code: String
    
    /// The pin retreived from the user.
    let tx_code: String?
    
    enum CodingKeys: String, CodingKey, CaseIterable
    {
        case grant_type
        case tx_code
        case pre_authorized_code = "pre-authorized_code"
    }
    
    func allProperties() -> [String : String?] {
        return [
            "grant_type": grant_type,
            "pre-authorized_code": pre_authorized_code,
            "tx_code": tx_code
        ]
    }
}
