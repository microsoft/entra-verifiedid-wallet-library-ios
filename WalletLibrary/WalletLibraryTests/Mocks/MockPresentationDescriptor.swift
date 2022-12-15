/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct MockPresentationDescriptor: Codable, Equatable {
    let encrypted: Bool?
    let claims: [MockClaimDescriptor]
    let presentationRequired: Bool?
    let credentialType: String
    let issuers: [MockIssuerDescriptor]?
    let contracts: [String]?

    enum CodingKeys: String, CodingKey {
        case encrypted, claims
        case presentationRequired = "required"
        case credentialType, issuers, contracts
    }
}
