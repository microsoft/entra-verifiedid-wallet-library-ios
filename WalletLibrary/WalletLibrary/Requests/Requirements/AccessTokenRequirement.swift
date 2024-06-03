/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe an access token required for a Verified Id issuance flow.
 */
public class AccessTokenRequirement: Requirement, InternalAccessTokenRequirement
{
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
    
    /// The access token that fulfills the requirement.
    var accessToken: String?
    
    init(encrypted: Bool = false,
         required: Bool = true,
         configuration: String,
         clientId: String? = nil,
         resourceId: String,
         scope: String) {
        self.encrypted = encrypted
        self.required = required
        self.configuration = configuration
        self.clientId = clientId
        self.resourceId = resourceId
        self.scope = scope
    }
    
    /// Returns Failure Result if requirement is not fulfilled.
    public func validate() -> VerifiedIdResult<Void> {
        if accessToken == nil {
            return VerifiedIdErrors.RequirementNotMet(message: "Access Token has not been set.").result()
        }
        
        return VerifiedIdResult.success(())
    }
    
    /// Fulfill requirement with a raw access token.
    public func fulfill(with rawToken: String) {
        accessToken = rawToken
    }
    
    public func serialize<T>(protocolSerializer: RequestProcessorSerializing,
                             verifiedIdSerializer: any VerifiedIdSerializing<T>) throws -> T?
    {
        throw VerifiedIdError(message: "Serialization not enabled for issuance",
                              code: "unsupported_serialization_method")
    }
}
