/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Raw OpenID4VCI Completion Request Data Model to send to back to requester
 * after issuance has completed.
 */
struct OpenID4VCICompletionRequest: Encodable
{
    /// The available codes to send.
    enum Code: String
    {
        case IssuanceSuccessful = "issuance_successful"
        case IssuanceFailed = "issuance_failed"
    }
    
    /// The result of the issuance.
    let code: String
    
    /// The issuer state from the credential offering.
    let state: String
    
    init(code: Code, state: String) 
    {
        self.code = code.rawValue
        self.state = state
    }
}
