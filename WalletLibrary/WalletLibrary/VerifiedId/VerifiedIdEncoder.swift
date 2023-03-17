/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdEncoderError: Error {
    case unsupportedVerifiedIdType(String)
}

public struct VerifiedIdEncoder {
    
    private let jsonEncoder = JSONEncoder()
    
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
