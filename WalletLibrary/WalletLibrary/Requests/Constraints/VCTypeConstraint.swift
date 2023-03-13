/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct VCTypeConstraint: VerifiedIdConstraint {
    
    let type: String

    func doesMatch(verifiedId: VerifiedId) -> Bool {
        guard let verifiableCredential = verifiedId as? VerifiableCredential else {
            return false
        }
        
        return verifiableCredential.types.contains(where: { $0 == type })
    }
    
    func doesMatch(verifiedId: VerifiedId) throws {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
}
