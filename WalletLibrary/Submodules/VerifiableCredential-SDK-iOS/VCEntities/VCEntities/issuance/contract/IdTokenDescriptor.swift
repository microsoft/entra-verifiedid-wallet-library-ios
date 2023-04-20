/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct IdTokenDescriptor: Codable, Equatable {
    
    public let encrypted: Bool?
    public let claims: [ClaimDescriptor]
    public let idTokenRequired: Bool?
    public let configuration: String
    public let clientID: String
    public let redirectURI: String?
    public let scope: String?

    enum CodingKeys: String, CodingKey {
        case encrypted, claims
        case idTokenRequired = "required"
        case configuration
        case clientID = "client_id"
        case redirectURI = "redirect_uri"
        case scope
    }
    
    public init(encrypted: Bool? = nil,
                claims: [ClaimDescriptor],
                idTokenRequired: Bool? = nil,
                configuration: String,
                clientID: String,
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
