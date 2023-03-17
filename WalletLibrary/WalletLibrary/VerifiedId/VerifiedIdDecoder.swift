/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Verified Id Decoder
 */
public struct VerifiedIdDecoder {
    
    let jsonDecoder = JSONDecoder()
    
    public init() {}
    
    public func decode(from data: Data) throws -> any VerifiedId {
        let encodedVerifiedId = try jsonDecoder.decode(EncodedVerifiedId.self, from: data)
        switch encodedVerifiedId.type {
        case .VerifiableCredential:
            return try jsonDecoder.decode(VerifiableCredential.self, from: encodedVerifiedId.raw)
        }
    }
}

enum VerifiedIdEncoderError: Error {
    case unsupportedVerifiedIdType(String)
}

public struct VerifiedIdEncoder {
    
    let jsonEncoder = JSONEncoder()
    
    public init() {}
    
    public func encode(verifiedId: any VerifiedId) throws -> Data {
        switch verifiedId {
        case let vc as VerifiableCredential:
            let rawVC = try jsonEncoder.encode(vc)
            let encodedVerifiedId = EncodedVerifiedId(type: .VerifiableCredential,
                                                      raw: rawVC)
            return try jsonEncoder.encode(encodedVerifiedId)
        default:
            let type = String(describing: type(of: verifiedId))
            throw VerifiedIdEncoderError.unsupportedVerifiedIdType(type)
        }
    }
}

struct EncodedVerifiedId: Codable {
    let type: SupportedVerifiedIdType
    
    let raw: Data
}

enum SupportedVerifiedIdType: String, Codable {
    case VerifiableCredential = "VerifiableCredential"
}
