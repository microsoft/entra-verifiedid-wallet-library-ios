/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Verified Id Decoder
 */
public struct VerifiedIdDecoder {
    
    private let jsonDecoder = JSONDecoder()
    
    public init() {}
    
    public func decode(from data: Data) throws -> any VerifiedId {
        let encodedVerifiedId = try jsonDecoder.decode(EncodedVerifiedId.self, from: data)
        switch encodedVerifiedId.type {
        case .VerifiableCredential:
            return try jsonDecoder.decode(VerifiableCredential.self, from: encodedVerifiedId.raw)
        }
    }
}
