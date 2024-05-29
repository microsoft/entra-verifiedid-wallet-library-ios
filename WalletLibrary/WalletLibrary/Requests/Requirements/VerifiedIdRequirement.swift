/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe Verified IDs required.
 */
public class VerifiedIdRequirement: Requirement 
{
    /// If requirement must be encrypted.
    let encrypted: Bool
    
    /// If the requirement is required or not.
    public let required: Bool
    
    /// The type of the verified Id required.
    public let types: [String]
    
    /// The purpose for the verified Id, developer can display to the user if desired.
    public let purpose: String?
    
    /// An optional property for information needed for issuance during presentation flow.
    public let issuanceOptions: [VerifiedIdRequestInput]
    
    /// Optional id of requirement defined by the request.
    public let id: String?
    
    /// Constraint defines how the requirement can be fulfilled.
    let constraint: VerifiedIdConstraint
    
    /// The verified id that was selected.
    var selectedVerifiedId: VerifiedId?
    
    init(encrypted: Bool,
         required: Bool,
         types: [String],
         purpose: String?,
         issuanceOptions: [VerifiedIdRequestInput],
         id: String?,
         constraint: VerifiedIdConstraint) 
    {
        self.encrypted = encrypted
        self.required = required
        self.types = types
        self.purpose = purpose
        self.issuanceOptions = issuanceOptions
        self.id = id
        self.constraint = constraint
    }
    
    /// Returns Failure Result is requirement constraint is not met.
    public func validate() -> VerifiedIdResult<Void> 
    {
        guard let selectedVerifiedId = self.selectedVerifiedId else 
        {
            return VerifiedIdErrors.RequirementNotMet(message: "Verified Id has not been set.").result()
        }
        
        do 
        {
            try constraint.matches(verifiedId: selectedVerifiedId)
        } 
        catch
        {
            return VerifiedIdErrors.RequirementNotMet(message: "Verified Id Constraints do not match.", errors: [error]).result()
        }
        
        return VerifiedIdResult.success(())
    }
    
    /// Given a list of Verified Ids, return a filtered list of Verified Ids that satisfy the requirement.
    public func getMatches(verifiedIds: [VerifiedId]) -> [VerifiedId] 
    {
        return verifiedIds.filter {
            constraint.doesMatch(verifiedId: $0)
        }
    }
    
    /// Fulfill the requirement with a VerifiedId. Returns Failure Result if Verified Id does not satisfy the requirement.
    public func fulfill(with verifiedId: VerifiedId) -> VerifiedIdResult<Void> 
    {
        do 
        {
            try constraint.matches(verifiedId: verifiedId)
        } 
        catch
        {
            return VerifiedIdErrors.RequirementNotMet(message: "Verified Id Constraints do not match.", errors: [error]).result()
        }
        
        self.selectedVerifiedId = verifiedId
        return VerifiedIdResult.success(())
    }
    
    public func serialize<T>(protocolSerializer: RequestProcessorSerializing, 
                             verifiedIdSerializer: any VerifiedIdSerializing<T>) throws -> T?
    {
        guard let verifiedId = selectedVerifiedId else 
        {
            return nil
        }
        
        return try verifiedIdSerializer.serialize(verifiedId: verifiedId)
    }
}
