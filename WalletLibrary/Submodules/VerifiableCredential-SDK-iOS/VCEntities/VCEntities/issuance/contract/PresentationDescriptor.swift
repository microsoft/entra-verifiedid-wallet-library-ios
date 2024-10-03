/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct PresentationDescriptor: Codable, Equatable {
    
    let encrypted: Bool?
    let claims: [ClaimDescriptor]
    let presentationRequired: Bool?
    let credentialType: String
    let issuers: [IssuerDescriptor]?
    let contracts: [String]?

    enum CodingKeys: String, CodingKey {
        case encrypted, claims
        case presentationRequired = "required"
        case credentialType, issuers, contracts
    }
    
    init(encrypted: Bool? = nil,
         claims: [ClaimDescriptor],
         presentationRequired: Bool? = nil,
         credentialType: String,
         issuers: [IssuerDescriptor]? = nil,
         contracts: [String]? = nil) {
        self.encrypted = encrypted
        self.claims = claims
        self.presentationRequired = presentationRequired
        self.credentialType = credentialType
        self.issuers = issuers
        self.contracts = contracts
    }
}
