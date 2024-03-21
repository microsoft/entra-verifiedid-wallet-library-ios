/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockClaims: Claims, Equatable 
{
    let key: String
    
    let iat: Int?
    
    let exp: Int?
    
    init(key: String, iat: Int? = nil, exp: Int? = nil)
    {
        self.key = key
        self.iat = iat
        self.exp = exp
    }
}
