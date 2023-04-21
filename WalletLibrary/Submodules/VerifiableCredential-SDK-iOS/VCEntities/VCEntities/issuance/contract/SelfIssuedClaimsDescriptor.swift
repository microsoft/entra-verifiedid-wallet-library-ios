/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct SelfIssuedClaimsDescriptor: Codable, Equatable {
    
    let encrypted: Bool?
    let claims: [ClaimDescriptor]?
    let selfIssuedRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case encrypted, claims
        case selfIssuedRequired = "required"
    }
    
    init(encrypted: Bool? = nil,
                claims: [ClaimDescriptor]? = nil,
                selfIssuedRequired: Bool? = nil) {
        self.encrypted = encrypted
        self.claims = claims
        self.selfIssuedRequired = selfIssuedRequired
    }
}
