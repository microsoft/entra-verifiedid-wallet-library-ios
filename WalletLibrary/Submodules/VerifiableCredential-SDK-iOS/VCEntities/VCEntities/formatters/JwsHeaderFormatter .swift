/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct JwsHeaderFormatter 
{
    static let jwtType = "JWT"
    
    func formatHeaders(usingIdentifier identifier: Identifier, 
                       andSigningKey key: KeyContainer,
                       type: String = Self.jwtType) -> Header 
    {
        let keyId = identifier.longFormDid + "#" + key.keyId
        return Header(type: type, algorithm: key.algorithm, keyId: keyId)
    }
}
