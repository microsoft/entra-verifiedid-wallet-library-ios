/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdEncoderError: Error {
    case unableToEncodeVerifiedId
}

/**
 * The Verified Id Encoder encodes a Verified Id, adds a type to an EncodedVerifiedId, and encodes again.
 * Post Private Preview: make supported id types injectable.
 */
struct VerifiedIdEncoder: VerifiedIdEncoding {

    private let jsonEncoder = JSONEncoder()
    
    func encode(verifiedId: VerifiedId) throws -> Data {
        do {
            let rawVerifiedId = try jsonEncoder.encode(verifiedId)
            let encodedVerifiedId = EncodedVerifiedId(type: String(describing: type(of: verifiedId)), raw: rawVerifiedId)
            return try jsonEncoder.encode(encodedVerifiedId)
        } catch {
            throw VerifiedIdEncoderError.unableToEncodeVerifiedId
        }
    }
}
