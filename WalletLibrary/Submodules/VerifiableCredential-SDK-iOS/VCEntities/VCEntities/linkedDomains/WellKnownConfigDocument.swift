/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

enum WellKnownConfigDocumentError: Error {
    case unableToParseLinkedDidToken
}

public struct WellKnownConfigDocument: Codable {
    let context: String
    public let linkedDids: [DomainLinkageCredential]
    
    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case linkedDids = "linked_dids"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.context = try values.decode(String.self, forKey: .context)
        let encodedTokens: [String] = try values.decode([String].self, forKey: .linkedDids)
        self.linkedDids = try encodedTokens.map { try Self.getCredential(from: $0) }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(context, forKey: .context)
        let encodedTokens = try self.linkedDids.map { try $0.serialize() }
        try container.encodeIfPresent(encodedTokens, forKey: .linkedDids)
    }
    
    private static func getCredential(from encodedCredential: String) throws -> DomainLinkageCredential {
        let nullableCredential = DomainLinkageCredential(from: encodedCredential)
        
        guard let credential = nullableCredential else {
            throw WellKnownConfigDocumentError.unableToParseLinkedDidToken
        }
        
        return credential
    }
}
