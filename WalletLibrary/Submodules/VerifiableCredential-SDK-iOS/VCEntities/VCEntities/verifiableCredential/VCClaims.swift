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
public struct VCClaims: Claims {
    public let jti: String?
    public let iss: String?
    public let sub: String?
    public let iat: Double?
    public let exp: Double?
    public let vc: VerifiableCredentialDescriptor?
    
    public init(jti: String?,
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
public typealias VerifiableCredential = JwsToken<VCClaims>
