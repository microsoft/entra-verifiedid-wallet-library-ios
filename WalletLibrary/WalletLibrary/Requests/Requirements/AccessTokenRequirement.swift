/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe an access token required for a Verified Id issuance flow.
 */
public struct AccessTokenRequirement {
    /// id of the requirement.
    let id: String
    
    /// if the requirement should be encrypted.
    let encrypted: Bool

    /// if the requirement is required or not.
    public let required: Bool
    
    /// The configuration url to get Access Token through an authentication library.
    public let configuration: String
    
    /// The client id used to get the access token through an authentication library
    public let clientId: String
    
    /// The resource id used to get the access token through an authentication library.
    public let resourceId: String
    
    /// The scope value used to get the access token through an authentication library.
    public let scope: String
}

