/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct SelfIssuedClaimsDescriptor: Codable, Equatable {
    
    public let encrypted: Bool?
    public let claims: [ClaimDescriptor]?
    public let selfIssuedRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case encrypted, claims
        case selfIssuedRequired = "required"
    }
    
    public init(encrypted: Bool? = nil,
                claims: [ClaimDescriptor]? = nil,
                selfIssuedRequired: Bool? = nil) {
        self.encrypted = encrypted
        self.claims = claims
        self.selfIssuedRequired = selfIssuedRequired
    }
}
