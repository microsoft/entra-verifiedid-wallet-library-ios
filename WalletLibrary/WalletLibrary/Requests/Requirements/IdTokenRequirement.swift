/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum IdTokenRequirementError: Error {
    case idTokenRequirementHasNotBeenFulfilled
}

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
    public let clientId: String
    
    /// The redirect url used to get the id token through an authentication library.
    public let redirectUri: String
    
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
         clientId: String,
         redirectUri: String,
         scope: String?) {
        self.encrypted = encrypted
        self.required = required
        self.configuration = configuration
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.scope = scope
    }
    
    /// Returns Failure Result if requirement is not fulfilled.
    public func validate() -> Result<Void, Error> {
        if idToken == nil {
            return Result.failure(IdTokenRequirementError.idTokenRequirementHasNotBeenFulfilled)
        }
        
        return Result.success(())
    }
    
    /// Fulfill requirement with a raw id token.
    public func fulfill(with rawToken: String) {
        idToken = rawToken
    }
}
