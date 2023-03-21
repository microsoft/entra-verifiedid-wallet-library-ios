/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdDecoderError: Error {
    case unsupportedVerifiedIdType
    case unableToDecodeVerifiedId
    case unableToDecodeVerifiedIdRawData
}
/**
 * The Verified Id Decoder 
 */
public struct VerifiedIdDecoder {

    private let jsonDecoder = JSONDecoder()
    
    private let supportedVerifiedIdTypes: [String: VerifiedId.Type]

    public init() {
        self.supportedVerifiedIdTypes = [SupportedVerifiedIdType.VerifiableCredential.rawValue: VerifiableCredential.self]
    }
    
    init(supportedVerifiedIdTypes: [String: VerifiedId.Type]) {
        self.supportedVerifiedIdTypes = supportedVerifiedIdTypes
    }

    public func decode(from data: Data) throws -> any VerifiedId {
        do {
            let encodedVerifiedId = try jsonDecoder.decode(EncodedVerifiedId.self, from: data)
            for (key,value) in supportedVerifiedIdTypes {
                if key == encodedVerifiedId.type {
                    return try jsonDecoder.decode(value, from: encodedVerifiedId.raw)
                }
            }
        } catch {
            throw VerifiedIdDecoderError.unableToDecodeVerifiedId
        }
        
        throw VerifiedIdDecoderError.unsupportedVerifiedIdType
    }
}
