/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct DomainLinkageCredentialSubject: Codable {
    let did: String
    let domainUrl: String
    
    enum CodingKeys: String, CodingKey {
        case did = "id"
        case domainUrl = "origin"
    }
}
