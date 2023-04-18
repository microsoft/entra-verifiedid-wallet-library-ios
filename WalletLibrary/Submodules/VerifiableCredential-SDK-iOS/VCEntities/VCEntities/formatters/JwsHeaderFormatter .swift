/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

struct JwsHeaderFormatter {
    
    static let jwtType = "JWT"
    
    func formatHeaders(usingIdentifier identifier: Identifier, andSigningKey key: KeyContainer) -> Header {
        let keyId = identifier.longFormDid + "#" + key.keyId
        return Header(type: JwsHeaderFormatter.jwtType, algorithm: key.algorithm, keyId: keyId)
    }
}
