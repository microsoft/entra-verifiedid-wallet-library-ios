/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/


import Foundation
@testable import VCCrypto

final class SigningMock: Signing {
    
    static var wasIsValidSignatureCalled = false
    
    static var wasSignCalled = false
    
    static var wasCreatePublicKeyCalled = false
    
    let signingResult: Data
    
    let isValidSignatureResult: Bool
    
    let createPublicKeyResult: PublicKey
    
    init(signingResult: Data = Data(count: 32),
         isValidSignatureResult: Bool = true,
         createPublicKeyResult: PublicKey = PublicKeyMock()) {
        self.signingResult = signingResult
        self.isValidSignatureResult = isValidSignatureResult
        self.createPublicKeyResult = createPublicKeyResult
    }
    
    func sign(message: Data, withSecret secret: VCCryptoSecret) throws -> Data {
        Self.wasSignCalled = true
        return signingResult
    }
    
    func isValidSignature(signature: Data, forMessage message: Data, usingPublicKey publicKey: PublicKey) throws -> Bool {
        Self.wasIsValidSignatureCalled = true
        return isValidSignatureResult
    }
    
    func createPublicKey(forSecret secret: VCCryptoSecret) throws -> PublicKey {
        Self.wasCreatePublicKeyCalled = true
        return createPublicKeyResult
    }
}
