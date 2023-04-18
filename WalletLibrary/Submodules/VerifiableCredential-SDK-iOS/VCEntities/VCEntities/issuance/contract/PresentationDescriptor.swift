/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct PresentationDescriptor: Codable, Equatable {
    
    public let encrypted: Bool?
    public let claims: [ClaimDescriptor]
    public let presentationRequired: Bool?
    public let credentialType: String
    public let issuers: [IssuerDescriptor]?
    public let contracts: [String]?

    enum CodingKeys: String, CodingKey {
        case encrypted, claims
        case presentationRequired = "required"
        case credentialType, issuers, contracts
    }
    
    public init(encrypted: Bool? = nil,
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
