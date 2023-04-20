/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct VerifiableCredentialDescriptor: Codable {
    let context: [String]?
    public let type: [String]?
    public let credentialSubject: Dictionary<String, Any>?
    let credentialStatus: ServiceDescriptor?
    let exchangeService: ServiceDescriptor?
    let revokeService: ServiceDescriptor?

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type, credentialSubject, credentialStatus, exchangeService, revokeService
    }
    
    public init(context: [String]?,
                type: [String]?,
                credentialSubject: Dictionary<String, Any>?,
                exchangeService: ServiceDescriptor? = nil) {
        self.context = context
        self.type = type
        self.credentialSubject = credentialSubject
        self.exchangeService = exchangeService
        self.credentialStatus = nil
        self.revokeService = nil
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        context = try values.decode([String].self, forKey: .context)
        type = try values.decode([String].self, forKey: .type)
        credentialStatus = try values.decodeIfPresent(ServiceDescriptor.self, forKey: .credentialStatus)
        exchangeService = try values.decodeIfPresent(ServiceDescriptor.self, forKey: .exchangeService)
        revokeService = try values.decodeIfPresent(ServiceDescriptor.self, forKey: .revokeService)
        credentialSubject = try values.decode(Dictionary<String, Any>.self, forKey: .credentialSubject)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(context, forKey: .context)
        try container.encode(type, forKey: .type)
        try container.encode(credentialSubject, forKey: .credentialSubject)
        try container.encodeIfPresent(credentialStatus, forKey: .credentialStatus)
        try container.encodeIfPresent(exchangeService, forKey: .exchangeService)
        try container.encodeIfPresent(revokeService, forKey: .revokeService)
    }
}
