/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import VCToken
import VCCrypto

class MockVerifier: TokenVerifying {
    func verify<T>(token: JwsToken<T>, usingPublicKey key: JWK) throws -> Bool where T : Claims {
        return true
    }
}
