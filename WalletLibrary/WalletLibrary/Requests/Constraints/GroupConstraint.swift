/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum GroupConstraintOperator {
    case ANY
    case ALL
}

enum GroupConstraintError: Error {
    case atleastOneConstraintDoesNotMatch(errors: [Error])
    case noConstraintsMatch(errors: [Error])
}

/**
 * A group of constraints.
 */
struct GroupConstraint: VerifiedIdConstraint {
    
    let constraints: [VerifiedIdConstraint]

    let constraintOperator: GroupConstraintOperator
    
    init(constraints: [VerifiedIdConstraint],
         constraintOperator: GroupConstraintOperator) {
        self.constraints = constraints
        self.constraintOperator = constraintOperator
    }
    
    /// If operator is equal to ANY, one constraint in constraints list must match.
    /// If operator is equal to ALL, all constraints must match.
    func doesMatch(verifiedId: VerifiedId) -> Bool {
        switch constraintOperator {
        case .ANY:
            return constraints.contains {
                $0.doesMatch(verifiedId: verifiedId)
            }
        case .ALL:
            return constraints.allSatisfy {
                $0.doesMatch(verifiedId: verifiedId)
            }
        }
    }
    
    func matches(verifiedId: VerifiedId) throws {
        
        var errorsThrown: [Error] = []
        for constraint in constraints {
            do {
                try constraint.matches(verifiedId: verifiedId)
            } catch {
                errorsThrown.append(error)
            }
        }
        
        switch constraintOperator {
        case .ANY:
            if errorsThrown.count == constraints.count {
                throw GroupConstraintError.noConstraintsMatch(errors: errorsThrown)
            }
        case .ALL:
            if !errorsThrown.isEmpty {
                throw GroupConstraintError.atleastOneConstraintDoesNotMatch(errors: errorsThrown)
            }
        }
    }
}
