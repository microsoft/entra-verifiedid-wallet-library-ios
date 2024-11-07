/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * A struct responsible for building DIDs (Decentralized Identifiers) from public keys.
 */
struct DIDBuilder
{
    /// Builds a DID from a given public key and method.
    /// - Parameters:
    ///   - publicKey: The public key to be used for building the DID. It must be compatible with ES256 (P-256 curve).
    ///   - method: The DID method to be used, currently supporting "did:jwk".
    /// - Throws: Throws an error if the public key is not an ES256PublicKey or if the method is not "did:jwk".
    /// - Returns: A string representing the generated DID in the format "did:jwk:<base64url-encoded JWK>".
    func build(from publicKey: PublicKey, method: String) throws -> String
    {
        // Only support ES256 keys and did:jwk method for now.
        guard let ecPublicKey = publicKey as? ES256PublicKey else
        {
            throw IdentifierError(message: "Invalid Key Type: \(type(of: publicKey)).",
                                  code: "invalid_public_key")
        }
        
        guard method == "did:jwk" else
        {
            throw IdentifierError(message: "Unsupported DID Method: \(method).",
                                  code: "unsupported_did_method")
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
