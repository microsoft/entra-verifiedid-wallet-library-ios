/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

enum MockCryptoError: Error {
    case ExpectedToThrow
}

class MockCryptoOperations: CryptoOperating {

    var verifyResult: Bool = true
    var throwWhenGettingPublicKey: Bool = false
    var signingResult: Data?
    var publicKey: PublicKey?
    
    static var wasSignCalled = false
    static var wasVerifyCalled = false
    static var wasGetPublicKeyCalled = false
    
    init(verifyResult: Bool = true) {
        self.verifyResult = verifyResult
    }
    
    init(signingResult: Data) {
        self.signingResult = signingResult
    }
    
    init(publicKey: PublicKey) {
        self.publicKey = publicKey
    }
    
    init(throwWhenGettingPublicKey: Bool) {
        self.throwWhenGettingPublicKey = throwWhenGettingPublicKey
    }
    
    func verify(signature: Data, forMessage message: Data, usingPublicKey publicKey: PublicKey) throws -> Bool {
        Self.wasVerifyCalled = true
        return verifyResult
    }
    
    func sign(message: Data, usingSecret secret: VCCryptoSecret, algorithm: String = "mock") throws -> Data {
        Self.wasSignCalled = true
        return signingResult ?? Data()
    }
    
    func getPublicKey(fromSecret secret: VCCryptoSecret, algorithm: String = "mock") throws -> PublicKey {
        Self.wasGetPublicKeyCalled = true
        return publicKey ?? Secp256k1PublicKey(x: Data(count: 32), y: Data(count: 32))!
    }
    
    func getPublicKey(fromJWK jwk: WalletLibrary.JWK) throws -> WalletLibrary.PublicKey {
        if throwWhenGettingPublicKey
        {
            throw MockCryptoError.ExpectedToThrow
        }
        
        return publicKey ?? Secp256k1PublicKey(x: Data(count: 32), y: Data(count: 32))!
    }
}
