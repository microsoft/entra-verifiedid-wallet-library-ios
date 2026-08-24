/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

extension JwsToken {
    func verify(
        using verifier: TokenVerifying,
        keys: [IdentifierDocumentPublicKey],
        keyIdentifier: DIDVerificationMethodIdentifier) throws -> Bool {
        for key in keys where key.matches(keyIdentifier) {
            if try verify(using: verifier, withPublicKey: key.publicKeyJwk) {
                return true
            }
        }

        return false
    }
}
