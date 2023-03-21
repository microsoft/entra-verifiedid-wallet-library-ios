/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdEncoderError: Error {
    case unsupportedVerifiedIdType
    case unableToEncodeVerifiedId
}

/**
 * The Verified Id Encoder.
 */
struct VerifiedIdEncoder {

    private let jsonEncoder = JSONEncoder()
    
    private let supportedVerifiedIdTypes: [String: VerifiedId.Type]

    init() {
        self.supportedVerifiedIdTypes = [SupportedVerifiedIdType.VerifiableCredential.rawValue: VerifiableCredential.self]
    }

    func encode(verifiedId: VerifiedId) throws -> Data {
        do {
            let rawVerifiedId = try jsonEncoder.encode(verifiedId)
            for (key, value) in supportedVerifiedIdTypes {
                if type(of: verifiedId) == value {
                    let encodedVerifiedId = EncodedVerifiedId(type: key, raw: rawVerifiedId)
                    return try jsonEncoder.encode(encodedVerifiedId)
                }
            }
            
            throw VerifiedIdEncoderError.unsupportedVerifiedIdType
            
        } catch {
            throw VerifiedIdEncoderError.unableToEncodeVerifiedId
        }
    }
}
