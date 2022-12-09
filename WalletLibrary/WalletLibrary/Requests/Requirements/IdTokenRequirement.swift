/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe an id token required for a Verified Id issuance flow.
 */
public struct IdTokenRequirement {
    /// id of the requirement
    let id: String
    
    /// if the requirement should be encrypted.
    let encrypted: Bool
    
    /// if the requirement is required or not.
    public let required: Bool
    
    /// The configuration url to get id token through an authentication library.
    public let configuration: URL
    
    /// The client id used to get the id token through an authentication library
    public let clientId: String
    
    /// The redirect url used to get the id token through an authentication library
    public let redirectUri: String
    
    /// The scope used to get the id token through an authentication library
    public let scope: String
    
    /// The nonce acts as an extra level of security and is used as an additional property
    /// within the id token request through an authentication library. The nonce will be placed within
    /// the id token retrieved and can be used for validation during an issuance request to an issuance service.
    public let nonce: String
}

