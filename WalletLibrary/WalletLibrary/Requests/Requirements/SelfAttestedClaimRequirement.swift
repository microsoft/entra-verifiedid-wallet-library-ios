/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe a self attested claim required for a Verified Id issuance flow.
 */
public class SelfAttestedClaimRequirement: Requirement {
    
    /// If the requirement should be encrypted.
    let encrypted: Bool
    
    /// If the requirement is required or not.
    public let required: Bool
    
    /// The claim requested.
    public let claim: String
    
    /// The claim value that fulfills the requirement.
    var value: String?
    
    init(encrypted: Bool, required: Bool, claim: String) {
        self.encrypted = encrypted
        self.required = required
        self.claim = claim
    }
    
    /// Returns Failure Result if requirement is not fulfilled.
    public func validate() -> VerifiedIdResult<Void> {
        if value == nil {
            return VerifiedIdErrors.RequirementNotMet(message: "Self Attested Claim has not been set.").result()
        }
        
        return VerifiedIdResult.success(())
    }
    
    /// Fulfill requirement with a self-attested value.
    public func fulfill(with value: String) {
        self.value = value
    }
    
    public func serialize<T>(protocolSerializer: RequestProcessorSerializing, verifiedIdSerializer: any VerifiedIdSerializing<T>) throws -> T? {
            switch (verifiedIdSerializer) {
            case _ as any VerifiedIdSerializing<String>:
                return value as! T?
            default:
                return nil
            }
    }
}
