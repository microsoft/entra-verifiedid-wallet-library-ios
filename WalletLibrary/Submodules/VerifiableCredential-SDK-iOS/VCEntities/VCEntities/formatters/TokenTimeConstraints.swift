/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/


struct TokenTimeConstraints 
{
    let issuedAt: Int
    let expiration: Int
    
    init(expiryInSeconds: Int) 
    {
        self.issuedAt = Int((Date().timeIntervalSince1970).rounded(.down))
        self.expiration = self.issuedAt + expiryInSeconds
    }
}
