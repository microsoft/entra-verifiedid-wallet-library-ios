/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe an access token required for a Verified Id issuance flow.
 */
public class AccessTokenRequirement: Requirement {
        
    /// If the requirement should be encrypted.
    let encrypted: Bool

    /// If the requirement is required or not.
    public let required: Bool
    
    /// The configuration url to get Access Token through an authentication library.
    public let configuration: String
    
    /// The optional client id used to get the access token through an authentication library.
    public let clientId: String?
    
    /// The resource id used to get the access token through an authentication library.
    public let resourceId: String
    
    /// The scope value used to get the access token through an authentication library.
    public let scope: String
    
    
    init(encrypted: Bool,
         required: Bool,
         configuration: String,
         clientId: String?,
         resourceId: String,
         scope: String) {
        self.encrypted = encrypted
        self.required = required
        self.configuration = configuration
        self.clientId = clientId
        self.resourceId = resourceId
        self.scope = scope
    }
    
    
    public func validate() throws { }
}

