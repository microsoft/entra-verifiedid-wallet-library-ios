/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import CryptoKit
@testable import WalletLibrary

class P256Tests: XCTestCase
{
    func testIsValidSignature_WithMatchingMessage_ReturnsTrue()
    {
        // Arrange
        let privateKey = P256.Signing.PrivateKey()
        let message = "hello world".data(using: .utf8)!
        let signature = try! privateKey.signature(for: message)
        
        let rawRepresentation = privateKey.publicKey.rawRepresentation
        let publicKey = P256PublicKey(uncompressedPublicKey: rawRepresentation)!
        let algorithm = WalletLibrary.P256()
        
        do {
            // Act
            let isValidSignature = try algorithm.isValidSignature(signature: signature.rawRepresentation,
                                                                  forMessage: message,
                                                                  usingPublicKey: publicKey)
            
            // Assert
            XCTAssertTrue(isValidSignature)
        } catch {
            XCTFail("Signature verification failed: \(error)")
        }
    }
    
    func testIsValidSignature_WithInvalidSignature_ReturnsFalse()
    {
        // Arrange
        let privateKey = P256.Signing.PrivateKey()
        let message = "hello world".data(using: .utf8)!
        let incorrectSignature = "r6tHorc/PUla5x+/YFIifwuD4VX9H8jobF0GnlfKGGz0k36GRPDZ4gHWMnRuOeMuQNW1oqCWgQ/HbmRBT3vN5A=="
        let incorrectSignatureEncoded = Data(base64Encoded: incorrectSignature)!
        
        let rawRepresentation = privateKey.publicKey.rawRepresentation
        let publicKey = P256PublicKey(uncompressedPublicKey: rawRepresentation)!
        let algorithm = WalletLibrary.P256()
        
        do {
            // Act
            let isValidSignature = try algorithm.isValidSignature(signature: incorrectSignatureEncoded,
                                                                  forMessage: message,
                                                                  usingPublicKey: publicKey)
            
            // Assert
            XCTAssertFalse(isValidSignature)
        } catch {
            XCTFail("Signature verification failed: \(error)")
        }
    }
    
    func testIsValidSignature_WithLongMessage_ReturnsTrue()
    {
        // Arrange
        let message = "eyJpZCI6ImIzZDk4Y2JiLTkxNGQtNGI2MC1hNzliLTFiZmRhZDNhYTc3MyIsImRpc3BsYXkiOnsibG9jYWxlIjoiZW4tVVMiLCJjb250cmFjdCI6Imh0dHBzOi8vc3RhZ2luZy5kaWQubXNpZGVudGl0eS5jb20vdjEuMC90ZW5hbnRzLzVlYWJhZmEwLTVhYmYtNDdhNy1hNzQwLTRlZDgwOTA1ZmY0My92ZXJpZmlhYmxlQ3JlZGVudGlhbHMvY29udHJhY3RzL2IzZDk4Y2JiLTkxNGQtNGI2MC1hNzliLTFiZmRhZDNhYTc3My9tYW5pZmVzdCIsImNhcmQiOnsidGl0bGUiOiJOYW1lIFRhZyIsImlzc3VlZEJ5IjoiRGVjZW50cmFsaXplZCBJZGVudGl0eSBUZWFtIiwiYmFja2dyb3VuZENvbG9yIjoiIzQxOERFMyIsInRleHRDb2xvciI6IiNGOEY4RkYiLCJsb2dvIjp7InVyaSI6Imh0dHBzOi8vc3dlZXBzdGFrZXMuZGlkLm1pY3Jvc29mdC5jb20vaW1hZ2VzL3doaXRlWGJveExvZ28ucG5nIiwiZGVzY3JpcHRpb24iOiJBdXRoZW50aWNhdG9yIEFwcCBsb2dvIn0sImRlc2NyaXB0aW9uIjoiVGhpcyBpcyBhIHRlc3QgUG9ydGFibGUgSWRlbnRpdHkgQ2FyZC4ifSwiY29uc2VudCI6eyJ0aXRsZSI6IkRvIHlvdSB3YW50IHRvIGdldCB5b3VyIHBlcnNvbmFsIG5hbWUgdGFnPyIsImluc3RydWN0aW9ucyI6IllvdSB3aWxsIG5lZWQgdG8gcHJlc2VudCB5b3VyIG5hbWUgaW4gb3JkZXIgdG8gZ2V0IHRoaXMgY2FyZC4ifSwiY2xhaW1zIjp7InZjLmNyZWRlbnRpYWxTdWJqZWN0Lm5hbWUiOnsidHlwZSI6IlN0cmluZyIsImxhYmVsIjoiTmFtZSJ9fSwiaWQiOiJkaXNwbGF5In0sImlucHV0Ijp7ImNyZWRlbnRpYWxJc3N1ZXIiOiJodHRwczovL3N0YWdpbmcuZGlkLm1zaWRlbnRpdHkuY29tL3YxLjAvdGVuYW50cy81ZWFiYWZhMC01YWJmLTQ3YTctYTc0MC00ZWQ4MDkwNWZmNDMvdmVyaWZpYWJsZUNyZWRlbnRpYWxzL2lzc3VlIiwiaXNzdWVyIjoiZGlkOndlYjp0ZXN0dG9rZW5wcm92aWRlci5henVyZXdlYnNpdGVzLm5ldDpjdXN0b206cGF0aCIsImF0dGVzdGF0aW9ucyI6eyJzZWxmSXNzdWVkIjp7ImlkIjoic2VsZkF0dGVzdGVkIiwiZW5jcnlwdGVkIjpmYWxzZSwiY2xhaW1zIjpbeyJjbGFpbSI6Im5hbWUiLCJyZXF1aXJlZCI6dHJ1ZSwiaW5kZXhlZCI6dHJ1ZX1dLCJyZXF1aXJlZCI6dHJ1ZX19LCJpZCI6ImlucHV0In0sImlzcyI6ImRpZDp3ZWI6dGVzdHRva2VucHJvdmlkZXIuYXp1cmV3ZWJzaXRlcy5uZXQ6Y3VzdG9tOnBhdGgiLCJpYXQiOjE2OTY0NTQwNjZ9".data(using: .utf8)!
        let privateKey = P256.Signing.PrivateKey()
        let signature = try! privateKey.signature(for: message)
        
        let rawRepresentation = privateKey.publicKey.rawRepresentation
        let publicKey = P256PublicKey(uncompressedPublicKey: rawRepresentation)!
        let algorithm = WalletLibrary.P256()
        
        do {
            // Act
            let isValidSignature = try algorithm.isValidSignature(signature: signature.rawRepresentation,
                                                                  forMessage: message,
                                                                  usingPublicKey: publicKey)
            
            // Assert
            XCTAssertTrue(isValidSignature)
        } catch {
            XCTFail("Signature verification failed: \(error)")
        }
    }
    
    func testCreatePublicKey_WithInvalidKeyType_ThrowsError()
    {
        // Arrange
        let mockInvalidKeyType = "Invalid Key Type"
        let mockX = Data(count: 32)
        let mockY = Data(count: 32)
        let jwk = JWK(keyType: mockInvalidKeyType,
                      keyId: "mock jwk",
                      key: nil,
                      curve: "P-256",
                      use: nil,
                      x: mockX,
                      y: mockY,
                      d: nil)
        let algorithm = WalletLibrary.P256()
        
        do {
            // Act
            let _ = try algorithm.createPublicKey(fromJWK: jwk)
            
            // Assert
            XCTFail()
        } catch {
            XCTAssert(error is P256Error)
            XCTAssertEqual(error as? P256Error, .JWKContainsInvalidKeyType(mockInvalidKeyType))
        }
    }
    
    func testCreatePublicKey_WithInvalidAlgorithm_ThrowsError()
    {
        // Arrange
        let mockInvalidAlgorithm = "Invalid Algorithm"
        let mockX = Data(count: 32)
        let mockY = Data(count: 32)
        let jwk = JWK(keyType: "EC",
                      keyId: "mock jwk",
                      key: nil,
                      curve: mockInvalidAlgorithm,
                      use: nil,
                      x: mockX,
                      y: mockY,
                      d: nil)
        let algorithm = WalletLibrary.P256()
        
        do {
            // Act
            let _ = try algorithm.createPublicKey(fromJWK: jwk)
            
            // Assert
            XCTFail()
        } catch {
            XCTAssert(error is P256Error)
            XCTAssertEqual(error as? P256Error, .JWKContainsInvalidCurveAlgorithm(mockInvalidAlgorithm))
        }
    }
    
    func testCreatePublicKey_WithMissingXValue_ThrowsError()
    {
        // Arrange
        let mockY = Data(count: 32)
        let jwk = JWK(keyType: "EC",
                      keyId: "mock jwk",
                      key: nil,
                      curve: "P-256",
                      use: nil,
                      x: nil,
                      y: mockY,
                      d: nil)
        let algorithm = WalletLibrary.P256()
        
        do {
            // Act
            let _ = try algorithm.createPublicKey(fromJWK: jwk)
            
            // Assert
            XCTFail()
        } catch {
            XCTAssert(error is P256Error)
            XCTAssertEqual(error as? P256Error, .MissingKeyMaterialInJWK)
        }
    }
    
    func testCreatePublicKey_WithInvalidKeyMaterial_ThrowsError()
    {
        // Arrange
        let mockX = Data(count: 33)
        let mockY = Data(count: 32)
        let jwk = JWK(keyType: "EC",
                      keyId: "mock jwk",
                      key: nil,
                      curve: "P-256",
                      use: nil,
                      x: mockX,
                      y: mockY,
                      d: nil)
        let algorithm = WalletLibrary.P256()
        
        do {
            // Act
            let _ = try algorithm.createPublicKey(fromJWK: jwk)
            
            // Assert
            XCTFail()
        } catch {
            XCTAssert(error is P256Error)
            XCTAssertEqual(error as? P256Error, .InvalidKeyMaterialInJWK)
        }
    }
    
    func testCreatePublicKey_WithValidJWK_ReturnsPublicKey()
    {
        // Arrange
        let mockX = Data(count: 32)
        let mockY = Data(count: 32)
        let jwk = JWK(keyType: "EC",
                      keyId: "mock jwk",
                      key: nil,
                      curve: "P-256",
                      use: nil,
                      x: mockX,
                      y: mockY,
                      d: nil)
        let algorithm = WalletLibrary.P256()
        
        do {
            // Act
            let publicKey = try algorithm.createPublicKey(fromJWK: jwk)
            
            // Assert
            XCTAssert(publicKey is P256PublicKey)
            XCTAssertEqual(publicKey.algorithm, "P-256")
            XCTAssertEqual((publicKey as? P256PublicKey)?.x, mockX)
            XCTAssertEqual((publicKey as? P256PublicKey)?.y, mockY)
        } catch {
            XCTFail("Signature verification failed: \(error)")
        }
    }
}

