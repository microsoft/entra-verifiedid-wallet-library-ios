/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

import XCTest
@testable import VCCrypto

class CryptoOperationsTests: XCTestCase {
    
    let mockMessageToSign = "testMessageToSign".data(using: .utf8)!
    
    let mockSecret = SecretMock(id: UUID(), withData: Data(count: 32))
    
    let mockSignature = "testSignature".data(using: .utf8)!
    
    let mockPublicKey = PublicKeyMock(algorithm: "mock")
    
    override func setUpWithError() throws {
        SigningMock.wasSignCalled = false
        SigningMock.wasCreatePublicKeyCalled = false
        SigningMock.wasIsValidSignatureCalled = false
    }
    
    func testSignWithAlgorithmThatSupportsSignOnly() throws {
        let mockSigningAlgorithms = ["MOCK": SigningAlgorithm(curve: "mock",
                                                             algorithm: SigningMock(signingResult: mockSignature),
                                                             supportedSigningOperations: [.Signing])]
        let cryptoOperations = CryptoOperations(signingAlgorithms: mockSigningAlgorithms)
        let signature = try cryptoOperations.sign(message: mockMessageToSign, usingSecret: mockSecret, algorithm: "mock")
        XCTAssertTrue(SigningMock.wasSignCalled)
        XCTAssertEqual(signature, mockSignature)
        
    }
    
    func testSignWithAlgorithmThatSupportsAllOperations() throws {
        let mockSigningAlgorithms = ["MOCK": SigningAlgorithm(curve: "mock",
                                                              algorithm: SigningMock(signingResult: mockSignature),
                                                              supportedSigningOperations: [.Verification, .Signing, .GetPublicKey])]
        let cryptoOperations = CryptoOperations(signingAlgorithms: mockSigningAlgorithms)
        let signature = try cryptoOperations.sign(message: mockMessageToSign, usingSecret: mockSecret, algorithm: "mock")
        XCTAssertTrue(SigningMock.wasSignCalled)
        XCTAssertEqual(signature, mockSignature)
        
    }
    
    func testSignWithInvalidAlgorithm() throws {
        let cryptoOperations = CryptoOperations()
        XCTAssertThrowsError(try cryptoOperations.sign(message: mockMessageToSign, usingSecret: mockSecret, algorithm: "mock")) { error in
            XCTAssertFalse(SigningMock.wasSignCalled)
            XCTAssertEqual(error as? CryptoOperationsError, CryptoOperationsError.signingAlgorithmNotSupported)
        }
    }
    
    func testSignWithAlgorithmWithSignNotSupported() throws {
        let mockSigningAlgorithms = ["MOCK": SigningAlgorithm(curve: "mock",
                                                              algorithm: SigningMock(signingResult: mockSignature),
                                                              supportedSigningOperations: [.Verification])]
        
        let cryptoOperations = CryptoOperations(signingAlgorithms: mockSigningAlgorithms)
        XCTAssertThrowsError(try cryptoOperations.sign(message: mockMessageToSign, usingSecret: mockSecret, algorithm: "mock")) { error in
            XCTAssertFalse(SigningMock.wasSignCalled)
            XCTAssertEqual(error as? CryptoOperationsError, CryptoOperationsError.signingAlgorithmDoesNotSupportSigning)
        }
        
    }
    
    func testVerificationWithAlgorithmThatSupportsVerificationOnly() throws {
        let mockSigningAlgorithms = ["MOCK": SigningAlgorithm(curve: "mock",
                                                              algorithm: SigningMock(isValidSignatureResult: true),
                                                              supportedSigningOperations: [.Verification])]
        let cryptoOperations = CryptoOperations(signingAlgorithms: mockSigningAlgorithms)
        let result = try cryptoOperations.verify(signature: mockSignature, forMessage: mockMessageToSign, usingPublicKey: mockPublicKey)
        XCTAssertTrue(SigningMock.wasIsValidSignatureCalled)
        XCTAssertTrue(result)
        
    }
    
    func testVerificationWithAlgorithmThatSupportsAllOperations() throws {
        let mockSigningAlgorithms = ["MOCK": SigningAlgorithm(curve: "mock",
                                                              algorithm: SigningMock(isValidSignatureResult: true),
                                                              supportedSigningOperations: [.Verification, .Signing, .GetPublicKey])]
        let cryptoOperations = CryptoOperations(signingAlgorithms: mockSigningAlgorithms)
        let result = try cryptoOperations.verify(signature: mockSignature, forMessage: mockMessageToSign, usingPublicKey: mockPublicKey)
        XCTAssertTrue(SigningMock.wasIsValidSignatureCalled)
        XCTAssertTrue(result)
    }
    
    func testVerificationWithInvalidSignature() throws {
        let mockSigningAlgorithms = ["MOCK": SigningAlgorithm(curve: "mock",
                                                              algorithm: SigningMock(isValidSignatureResult: false),
                                                              supportedSigningOperations: [.Verification, .Signing, .GetPublicKey])]
        let cryptoOperations = CryptoOperations(signingAlgorithms: mockSigningAlgorithms)
        let result = try cryptoOperations.verify(signature: mockSignature, forMessage: mockMessageToSign, usingPublicKey: mockPublicKey)
        XCTAssertTrue(SigningMock.wasIsValidSignatureCalled)
        XCTAssertFalse(result)
    }
    
    func testVerificationWithInvalidAlgorithm() throws {
        let cryptoOperations = CryptoOperations()
        XCTAssertThrowsError(try cryptoOperations.verify(signature: mockSignature,
                                                         forMessage: mockMessageToSign,
                                                         usingPublicKey: mockPublicKey)) { error in
            XCTAssertFalse(SigningMock.wasIsValidSignatureCalled)
            XCTAssertEqual(error as? CryptoOperationsError, CryptoOperationsError.signingAlgorithmNotSupported)
        }
    }
    
    func testVerificationWithAlgorithmWithVerificationNotSupported() throws {
        let mockSigningAlgorithms = ["MOCK": SigningAlgorithm(curve: "mock",
                                                              algorithm: SigningMock(signingResult: mockSignature),
                                                              supportedSigningOperations: [.Signing])]
        
        let cryptoOperations = CryptoOperations(signingAlgorithms: mockSigningAlgorithms)
        XCTAssertThrowsError(try cryptoOperations.verify(signature: mockSignature,
                                                         forMessage: mockMessageToSign,
                                                         usingPublicKey: mockPublicKey)) { error in
            XCTAssertFalse(SigningMock.wasIsValidSignatureCalled)
            XCTAssertEqual(error as? CryptoOperationsError, CryptoOperationsError.signingAlgorithmDoesNotSupportVerification)
        }
    }
    
    func testGetPublicKeyWithAlgorithmThatSupportsGetPublicKeyOnly() throws {
        let mockSigningAlgorithms = ["MOCK": SigningAlgorithm(curve: "mock",
                                                              algorithm: SigningMock(createPublicKeyResult: mockPublicKey),
                                                              supportedSigningOperations: [.GetPublicKey])]
        let cryptoOperations = CryptoOperations(signingAlgorithms: mockSigningAlgorithms)
        let result = try cryptoOperations.getPublicKey(fromSecret: mockSecret, algorithm: "mock")
        XCTAssertTrue(SigningMock.wasCreatePublicKeyCalled)
        XCTAssertEqual(mockPublicKey, result as? PublicKeyMock)
        
    }
    
    func testGetPublicKeyWithAlgorithmThatSupportsAllOperations() throws {
        let mockSigningAlgorithms = ["MOCK": SigningAlgorithm(curve: "mock",
                                                              algorithm: SigningMock(createPublicKeyResult: mockPublicKey),
                                                              supportedSigningOperations: [.GetPublicKey, .Signing, .Verification])]
        let cryptoOperations = CryptoOperations(signingAlgorithms: mockSigningAlgorithms)
        let result = try cryptoOperations.getPublicKey(fromSecret: mockSecret, algorithm: "mock")
        XCTAssertTrue(SigningMock.wasCreatePublicKeyCalled)
        XCTAssertEqual(mockPublicKey, result as? PublicKeyMock)
        
    }
    
    func testGetPublicKeyWithInvalidAlgorithm() throws {
        let cryptoOperations = CryptoOperations()
        XCTAssertThrowsError(try cryptoOperations.getPublicKey(fromSecret: mockSecret, algorithm: "mock")) { error in
            XCTAssertFalse(SigningMock.wasCreatePublicKeyCalled)
            XCTAssertEqual(error as? CryptoOperationsError, CryptoOperationsError.signingAlgorithmNotSupported)
        }
    }
    
    func testGetPublicKeyWithAlgorithmWithGetPublicKeyNotSupported() throws {
        let mockSigningAlgorithms = ["MOCK": SigningAlgorithm(curve: "mock",
                                                              algorithm: SigningMock(createPublicKeyResult: mockPublicKey),
                                                              supportedSigningOperations: [.Signing, .Verification])]
        
        let cryptoOperations = CryptoOperations(signingAlgorithms: mockSigningAlgorithms)
        XCTAssertThrowsError(try cryptoOperations.getPublicKey(fromSecret: mockSecret, algorithm: "mock")) { error in
            XCTAssertFalse(SigningMock.wasCreatePublicKeyCalled)
            XCTAssertEqual(error as? CryptoOperationsError, CryptoOperationsError.signingAlgorithmDoesNotSupportGetPublicKey)
        }
    }
}

