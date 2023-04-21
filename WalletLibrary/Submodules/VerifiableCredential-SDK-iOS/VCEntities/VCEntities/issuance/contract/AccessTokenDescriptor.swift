/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct AccessTokenDescriptor: Codable, Equatable {
    
    let id: String?
    let encrypted: Bool?
    let claims: [ClaimDescriptor]?
    let required: Bool?
    let configuration: String?
    let resourceId: String?
    let oboScope: String?
    
    init(id: String? = nil,
                encrypted: Bool? = nil,
                claims: [ClaimDescriptor]? = nil,
                required: Bool? = nil,
                configuration: String? = nil,
                resourceId: String? = nil,
                oboScope: String? = nil) {
        self.id = id
        self.encrypted = encrypted
        self.claims = claims
        self.required = required
        self.configuration = configuration
        self.resourceId = resourceId
        self.oboScope = oboScope
    }
}
