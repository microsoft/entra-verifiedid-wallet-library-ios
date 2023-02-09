/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Information to describe a group of requirements.
 */
public class GroupRequirement: Requirement {
    
    /// If the requirement is required or not.
    public let required: Bool
    
    public let requirements: [Requirement]
    
    public let requirementsOperator: Operator
    
    init(required: Bool,
         requirements: [Requirement],
         requirementsOperator: Operator) {
        self.required = required
        self.requirements = requirements
        self.requirementsOperator = requirementsOperator
    }
    
    public func validate() throws {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
}

public enum Operator {
    case ANY
    case ALL
}
