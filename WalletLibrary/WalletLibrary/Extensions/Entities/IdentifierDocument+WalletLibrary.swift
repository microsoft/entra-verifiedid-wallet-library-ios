/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * An extension of the VCEntities.IdentifierDocument class
 * to get Public JWK with specific ID from document.
 */
extension IdentifierDocument
{
    func getJWK(id: String, forDID did: String? = nil) -> JWK?
    {
        guard let publicKeys = verificationMethod else
        {
            return nil
        }
        
        guard let did else {
            return publicKeys.first(where: { $0.id == id })?.publicKeyJwk.toJWK()
        }

        guard let keyIdentifier = DIDVerificationMethodIdentifier(keyId: did + id) else {
            return nil
        }

        return publicKeys.first(where: { $0.matches(keyIdentifier) })?.publicKeyJwk.toJWK()
    }
}
