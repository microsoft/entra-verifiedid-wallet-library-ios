/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VCTypeConstraintError: Error, Equatable {
    case verifiedIdDoesNotHaveSpecifiedType(String)
}

/**
 * A Verifiable Credential specific constraint that checks to see if the VC's type matches a value.
 */
struct VCTypeConstraint: VerifiedIdConstraint {
    
    let type: String

    func doesMatch(verifiedId: VerifiedId) -> Bool {
        guard let verifiableCredential = verifiedId as? InternalVerifiedId else {
            return false
        }
        
        return verifiableCredential.types.contains(where: { $0 == type })
    }
    
    func matches(verifiedId: VerifiedId) throws {
        guard doesMatch(verifiedId: verifiedId) else {
            throw VCTypeConstraintError.verifiedIdDoesNotHaveSpecifiedType(type)
        }
    }
}
