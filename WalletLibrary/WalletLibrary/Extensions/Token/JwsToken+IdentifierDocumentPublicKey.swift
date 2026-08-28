/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

extension JwsToken {
    /// Attempts verification against every key matching `keyIdentifier`. Each key's verification
    /// is attempted independently (via `try?`) so a malformed or incompatible key does not abort
    /// the search for a later key that would otherwise verify successfully.
    func verify(
        using verifier: TokenVerifying,
        keys: [IdentifierDocumentPublicKey],
        keyIdentifier: DIDVerificationMethodIdentifier) -> Bool {
        for key in keys where key.matches(keyIdentifier) {
            if (try? verify(using: verifier, withPublicKey: key.publicKeyJwk)) == true {
                return true
            }
        }

        return false
    }
}
