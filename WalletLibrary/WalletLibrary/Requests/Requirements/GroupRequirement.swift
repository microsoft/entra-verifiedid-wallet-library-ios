/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum GroupRequirementError: Error {
    case requirementsAreNotValid([Error])
}

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
    
    internal(set) public var requirements: [Requirement]
    
    public let requirementOperator: GroupRequirementOperator
    
    init(required: Bool,
         requirements: [Requirement],
         requirementOperator: GroupRequirementOperator) {
        self.required = required
        self.requirements = requirements
        self.requirementOperator = requirementOperator
    }
    
    /// Throws error if requirement is not valid or incomplete.
    public func validate() throws {
        
        var errorsThrown: [Error] = []
        for requirement in requirements {
            do {
                try requirement.validate()
            } catch {
                errorsThrown.append(error)
            }
        }
        
        if !errorsThrown.isEmpty {
            throw GroupRequirementError.requirementsAreNotValid(errorsThrown)
        }
    }
}
