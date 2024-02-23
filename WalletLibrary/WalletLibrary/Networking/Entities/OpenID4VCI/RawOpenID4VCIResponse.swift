/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Raw Response from the Issuance Service that issues Wallet a Verified ID.
 */
struct RawOpenID4VCIResponse: Decodable
{
    /// The Verified ID issued.
    let credential: String?
    
    /// The notification id to pass to notification endpoint.
    let notification_id: String?
}
