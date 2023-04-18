/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct DomainLinkageCredentialContent: Codable {
    let context: [String]
    let issuer: String
    let issuanceDate: String
    let expirationDate: String
    let type: [String]
    let credentialSubject: DomainLinkageCredentialSubject
    
    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case issuer, issuanceDate, expirationDate, type, credentialSubject
    }
}
