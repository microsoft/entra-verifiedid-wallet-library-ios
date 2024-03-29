/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe an id token required for a Verified Id issuance flow.
 */
public class IdTokenRequirement: Requirement {

    /// If the requirement should be encrypted.
    let encrypted: Bool
    
    /// If the requirement is required or not.
    public let required: Bool
    
    /// The configuration url to get id token through an authentication library.
    public let configuration: URL
    
    /// The client id used to get the id token through an authentication library.
    public let clientId: String?
    
    /// The redirect url used to get the id token through an authentication library.
    public let redirectUri: String?
    
    /// The scope used to get the id token through an authentication library.
    public let scope: String?
    
    /// The nonce acts as an extra level of security and is used as an additional property
    /// within the id token request through an authentication library. The nonce will be placed within
    /// the id token retrieved and can be used for validation during an issuance request to an issuance service.
    public internal(set) var nonce: String? = nil
    
    /// The id token that fulfills the requirement.
    var idToken: String?
    
    init(encrypted: Bool,
         required: Bool,
         configuration: URL,
         clientId: String?,
         redirectUri: String?,
         scope: String?) {
        self.encrypted = encrypted
        self.required = required
        self.configuration = configuration
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.scope = scope
    }
    
    func add(nonce: String)
    {
        self.nonce = nonce
    }
    
    /// Returns Failure Result if requirement is not fulfilled.
    public func validate() -> VerifiedIdResult<Void> {
        if idToken == nil {
            return VerifiedIdErrors.RequirementNotMet(message: "Id Token has not been set.").result()
        }
        
        return Result.success(())
    }
    
    /// Fulfill requirement with a raw id token.
    public func fulfill(with rawToken: String) {
        idToken = rawToken
    }
    
    public func serialize<T>(protocolSerializer: RequestProcessorSerializing,
                             verifiedIdSerializer: any VerifiedIdSerializing<T>) throws -> T?
    {
        throw VerifiedIdError(message: "Serialization not enabled for issuance",
                              code: "unsupported_serialization_method")
    }
}
