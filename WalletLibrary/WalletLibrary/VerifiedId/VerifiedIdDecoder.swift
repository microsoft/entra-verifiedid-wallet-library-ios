/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdDecoderError: Error {
    case unsupportedVerifiedIdType
    case unableToDecodeVerifiedId
}

/**
 * The Verified Id Decoder decodes the data, determines what type of Verified Id the data represents, and returns that VerifiedId.
 * Post Private Preview: make supported types injectable.
 */
struct VerifiedIdDecoder: VerifiedIdDecoding {

    private let jsonDecoder = JSONDecoder()
    
    private let supportedVerifiedIdTypes: [VerifiedId.Type]

    init() {
        self.supportedVerifiedIdTypes = [VCVerifiedId.self, OpenID4VCIVerifiedId.self]
    }

    func decode(from data: Data) throws -> any VerifiedId {
        do {
            let encodedVerifiedId = try jsonDecoder.decode(EncodedVerifiedId.self, from: data)
            for type in supportedVerifiedIdTypes {
                if String(describing: type) == encodedVerifiedId.type {
                    return try jsonDecoder.decode(type, from: encodedVerifiedId.raw)
                }
            }
        } catch {
            throw VerifiedIdDecoderError.unableToDecodeVerifiedId
        }
        
        throw VerifiedIdDecoderError.unsupportedVerifiedIdType
    }
}
