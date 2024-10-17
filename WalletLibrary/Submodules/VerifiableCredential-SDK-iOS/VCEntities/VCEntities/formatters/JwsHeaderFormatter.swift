/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct JwsHeaderFormatter 
{
    static let jwtType = "JWT"
    
    func formatHeaders(identifier: String,
                       signingKey: KeyContainer,
                       type: String = Self.jwtType) -> Header
    {
        let keyId = identifier + "#" + signingKey.keyId
        return Header(type: type, algorithm: signingKey.algorithm, keyId: keyId)
    }
    
    func formatHeaders(identifier: HolderIdentifier,
                       type: String = Self.jwtType) -> Header
    {
        let keyId = identifier.id + "#" + identifier.keyReference
        return Header(type: type, algorithm: identifier.algorithm, keyId: keyId)
    }
}
