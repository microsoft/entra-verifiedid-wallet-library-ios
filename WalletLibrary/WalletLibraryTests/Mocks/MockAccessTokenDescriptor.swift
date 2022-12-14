/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct MockAccessTokenDescriptor: Codable, Equatable {
    let id: String?
    let encrypted: Bool?
    let claims: [MockClaimDescriptor]?
    let required: Bool?
    let configuration: String?
    let resourceId: String?
    let oboScope: String?
}
