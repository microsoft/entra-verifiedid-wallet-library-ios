/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct DomainLinkageCredentialClaims: Claims {
    let subject: String
    let issuer: String
    let notValidBefore: Int
    let verifiableCredential: DomainLinkageCredentialContent
    
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case issuer = "iss"
        case notValidBefore = "nbf"
        case verifiableCredential = "vc"
    }
}

typealias DomainLinkageCredential = JwsToken<DomainLinkageCredentialClaims>
