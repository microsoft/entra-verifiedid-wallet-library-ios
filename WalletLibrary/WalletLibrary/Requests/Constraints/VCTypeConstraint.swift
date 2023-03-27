/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * A Verifiable Credential specific constraint that checks to see if the VC's type matches a value.
 */
struct VCTypeConstraint: VerifiedIdConstraint {
    
    let type: String

    func doesMatch(verifiedId: VerifiedId) -> Bool {
        guard let verifiableCredential = verifiedId as? VCVerifiedId else {
            return false
        }
        
        return verifiableCredential.types.contains(where: { $0 == type })
    }
}
