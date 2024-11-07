/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

struct DIDBuilder
{
    func build(from publicKey: PublicKey, method: String) throws -> String
    {
        // Only support ES256 keys and did:jwk method for now.
        guard let ecPublicKey = publicKey as? ES256PublicKey,
              method == "did:jwk" else
        {
            throw VerifiedIdError(message: "", code: "")
        }
        
        let jwk: [String: String] =
        [
            "crv": ecPublicKey.curve,
            "kty": ecPublicKey.keyType,
            "x": ecPublicKey.x.base64URLEncodedString(),
            "y": ecPublicKey.y.base64URLEncodedString()
        ]
        
        let serializedJWK = try JSONSerialization.data(withJSONObject: jwk)
        let base64EncodedJWK = serializedJWK.base64URLEncodedString()
        return "did:jwk:\(base64EncodedJWK)"
    }
}
