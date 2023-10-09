/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct IdTokenDescriptor: Codable, Equatable {
    
    let encrypted: Bool?
    let claims: [ClaimDescriptor]
    let idTokenRequired: Bool?
    let configuration: String
    let clientID: String?
    let redirectURI: String?
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case encrypted, claims
        case idTokenRequired = "required"
        case configuration
        case clientID = "client_id"
        case redirectURI = "redirect_uri"
        case scope
    }
    
    init(encrypted: Bool? = nil,
         claims: [ClaimDescriptor],
         idTokenRequired: Bool? = nil,
         configuration: String,
         clientID: String? = nil,
         redirectURI: String? = nil,
         scope: String? = nil) {
        self.encrypted = encrypted
        self.claims = claims
        self.idTokenRequired = idTokenRequired
        self.configuration = configuration
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.scope = scope
    }
}
