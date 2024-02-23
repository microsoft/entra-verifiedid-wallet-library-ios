/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

class MockSigner: TokenSigning 
{
    enum ExpectedError: Error
    {
        case SignExpectedToThrow
    }
    
    private let doesSignThrow: Bool
    
    init(doesSignThrow: Bool = false)
    {
        self.doesSignThrow = doesSignThrow
    }
    
    func sign<T : Claims>(token: JwsToken<T>, withSecret secret: VCCryptoSecret) throws -> Signature
    {
        if doesSignThrow
        {
            throw ExpectedError.SignExpectedToThrow
        }
        
        return "fakeSignature".data(using: .utf8)!
    }
    
    func getPublicJwk(from secret: VCCryptoSecret, withKeyId keyId: String) throws -> ECPublicJwk 
    {
        return ECPublicJwk(x: "x", y: "y", keyId: "keyId")
    }
    
}
