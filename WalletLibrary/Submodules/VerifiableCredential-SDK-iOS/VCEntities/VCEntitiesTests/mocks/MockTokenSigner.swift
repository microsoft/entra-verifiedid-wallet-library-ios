/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCToken
import VCCrypto

@testable import VCEntities

struct MockTokenSigner: TokenSigning {
    
    let x: String
    let y: String
    
    static var wasSignCalled = false
    static var wasGetPublicJwkCalled = false
    
    init(x: String, y: String) {
        self.x = x
        self.y = y
    }
    
    func sign<T>(token: JwsToken<T>, withSecret secret: VCCryptoSecret) throws -> Signature where T : Claims {
        MockTokenSigner.wasSignCalled = true
        return Data(count: 64)
    }
    
    func getPublicJwk(from secret: VCCryptoSecret, withKeyId keyId: String) throws -> ECPublicJwk {
        MockTokenSigner.wasGetPublicJwkCalled = true
        return ECPublicJwk(x: self.x, y: self.y, keyId: keyId)
    }
}
