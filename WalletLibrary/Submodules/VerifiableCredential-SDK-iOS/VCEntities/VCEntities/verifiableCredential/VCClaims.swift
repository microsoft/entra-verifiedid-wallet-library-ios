/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

/**
 * Contents of a Verifiable Credential Token.
 *
 * @see [Verifiable Credential Spec](https://www.w3.org/TR/vc-data-model/)
 */
struct VCClaims: Claims {
    let jti: String?
    let iss: String?
    let sub: String?
    let iat: Double?
    let exp: Double?
    let vc: VerifiableCredentialDescriptor?
    
    init(jti: String?,
                iss: String?,
                sub: String?,
                iat: Double?,
                exp: Double?,
                vc: VerifiableCredentialDescriptor?) {
        self.jti = jti
        self.iss = iss
        self.sub = sub
        self.iat = iat
        self.exp = exp
        self.vc = vc
    }
}

/// JWSToken representation of a Verifiable Credential.
typealias VerifiableCredential = JwsToken<VCClaims>
