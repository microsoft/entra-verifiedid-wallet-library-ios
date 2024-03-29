/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * This value specifies if all requirements are needed in the list or just one.
 */
public enum GroupRequirementOperator {
    case ANY
    case ALL
}

/**
 * Information to describe a group of requirements.
 */
public class GroupRequirement: Requirement {
    
    /// If the requirement is required or not.
    public let required: Bool
    
    /// The requirements contained within the group.
    internal(set) public var requirements: [Requirement]
    
    /// If operator is equal to ANY, one of the requirements must be fulfilled.
    /// If operator is equal to ALL, all requirements must be fulfilled.
    public let requirementOperator: GroupRequirementOperator
    
    init(required: Bool,
         requirements: [Requirement],
         requirementOperator: GroupRequirementOperator) {
        self.required = required
        self.requirements = requirements
        self.requirementOperator = requirementOperator
    }
    
    /// Returns Failure Result if requirement is not valid or not fulfilled.
    public func validate() -> VerifiedIdResult<Void> {
        
        var errorsThrown: [Error] = []
        for requirement in requirements {
            do {
                try requirement.validate().get()
            } catch {
                errorsThrown.append(error)
            }
        }
        
        if !errorsThrown.isEmpty {
            return VerifiedIdErrors.RequirementNotMet(message: "Group Requirement is not valid.",
                                                      errors: errorsThrown).result()
        }
        
        return VerifiedIdResult.success(())
    }
    
    
    public func serialize<T>(protocolSerializer: RequestProcessorSerializing, 
                             verifiedIdSerializer: any VerifiedIdSerializing<T>) throws -> T?
    {
        switch self.requirementOperator 
        {
        case .ANY:
            for requirement in requirements 
            {
                do {
                    try requirement.validate().get()
                    try protocolSerializer.serialize(requirement: requirement,
                                                     verifiedIdSerializer: verifiedIdSerializer)
                } catch {
                    // nothing needs to be done, this requirement won't be serialized
                }
            }
        case .ALL:
            for requirement in requirements
            {
                try protocolSerializer.serialize(requirement: requirement,
                                                 verifiedIdSerializer: verifiedIdSerializer)
            }
        }
        // this requirement has no serialization
        return nil
    }
}
