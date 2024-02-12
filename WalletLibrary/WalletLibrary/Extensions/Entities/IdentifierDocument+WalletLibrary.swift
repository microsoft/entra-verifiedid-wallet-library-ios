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
    func getJWK(id: String) -> JWK?
    {
        guard let publicKeys = verificationMethod else
        {
            return nil
        }
        
        for publicKey in publicKeys
        {
            if publicKey.id == id
            {
                return publicKey.publicKeyJwk.toJWK()
            }
        }
        
        return nil
    }
}
