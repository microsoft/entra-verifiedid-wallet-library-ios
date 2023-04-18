/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import VCToken
import VCCrypto

class MockSigner: TokenSigning {
    
    func sign<T>(token: JwsToken<T>, withSecret secret: VCCryptoSecret) throws -> Signature where T : Claims {
        return "fakeSignature".data(using: .utf8)!
    }
    
    func getPublicJwk(from secret: VCCryptoSecret, withKeyId keyId: String) throws -> ECPublicJwk {
        return ECPublicJwk(x: "x", y: "y", keyId: "keyId")
    }
    
}
