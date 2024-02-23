/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class SignedCredentialMetadataProcessorTests: XCTestCase
{
    func testProcess_WithInvalidRawRequest_ThrowsError() async throws
    {
        // Arrange
        let configuration = LibraryConfiguration()
        let processor = SignedCredentialMetadataProcessor(configuration: configuration)
        
        let malformedSignedMetadata = "malformed signed metadata"
        let credentialIssuer = "credentialIssuer"
        
        do
        {
            // Act
            let _ = try await processor.process(signedMetadata: malformedSignedMetadata,
                                                credentialIssuer: credentialIssuer)
        }
        catch
        {
            // Assert
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "signed_metadata_token_malformed")
            XCTAssertEqual(validationError.message, "Signed Metadata is not a JSON Web Token.")
        }
    }
    
    func testProcess_WithInvalidKeyId_ThrowsError() async throws
    {
        // Arrange
        let configuration = LibraryConfiguration()
        let processor = SignedCredentialMetadataProcessor(configuration: configuration)
        
        let metadataTokenClaims = SignedMetadataTokenClaims(sub: "", iss: "")
        
        let malformedSignedMetadata = SignedMetadata(headers: Header(keyId: "invalidKeyId"),
                                                     content: metadataTokenClaims)!
        let serializedMetadata = try malformedSignedMetadata.serialize()
        let credentialIssuer = "credentialIssuer"
        
        do
        {
            // Act
            let _ = try await processor.process(signedMetadata: serializedMetadata,
                                                credentialIssuer: credentialIssuer)
        }
        catch
        {
            // Assert
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "signed_metadata_token_malformed")
            XCTAssertEqual(validationError.message, "Unable to extract Key Id from Signed Metadata Token.")
        }
    }
    
    func testProcess_WithFailedToResolveDIDDocument_ThrowsError() async throws
    {
        // Arrange
        let mockIdentifierDocumentResolver = MockIdentifierDocumentResolver()
        let mockRootOfTrustResolver = MockRootOfTrustResolver()
        let processor = SignedCredentialMetadataProcessor(tokenVerifier: TokenVerifier(),
                                                          identifierDocumentResolver: mockIdentifierDocumentResolver,
                                                          rootOfTrustResolver: mockRootOfTrustResolver)
        
        let metadataTokenClaims = SignedMetadataTokenClaims(sub: "", iss: "")
        
        let signedMetadata = SignedMetadata(headers: Header(keyId: "did:test:mock#keyId"),
                                                     content: metadataTokenClaims)!
        let serializedMetadata = try signedMetadata.serialize()
        let credentialIssuer = "credentialIssuer"
        
        do
        {
            // Act
            let _ = try await processor.process(signedMetadata: serializedMetadata,
                                                credentialIssuer: credentialIssuer)
        }
        catch
        {
            // Assert
            XCTAssert(error is MockIdentifierDocumentResolver.ExpectedError)
        }
    }
    
    func testProcess_WithFailedToGetJWKFromDIDDocument_ThrowsError() async throws
    {
        // Arrange
        let mockDocumentResolver = MockIdentifierDocumentResolver(mockResolve: createMockResolve())
        let mockRootOfTrustResolver = MockRootOfTrustResolver()
        let processor = SignedCredentialMetadataProcessor(tokenVerifier: TokenVerifier(),
                                                          identifierDocumentResolver:mockDocumentResolver,
                                                          rootOfTrustResolver: mockRootOfTrustResolver)
        
        let metadataTokenClaims = SignedMetadataTokenClaims(sub: "", iss: "")
        
        let signedMetadata = SignedMetadata(headers: Header(keyId: "did:test:mock#keyId"),
                                                     content: metadataTokenClaims)!
        let serializedMetadata = try signedMetadata.serialize()
        let credentialIssuer = "credentialIssuer"
        
        do
        {
            // Act
            let _ = try await processor.process(signedMetadata: serializedMetadata,
                                                credentialIssuer: credentialIssuer)
        }
        catch
        {
            // Assert
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "signed_metadata_token_malformed")
            XCTAssertEqual(validationError.message, "Key Id not defined in Identifier Document.")
        }
    }
    
    func testProcess_WithClaimsInTokenInvalid_ThrowsError() async throws
    {
        // Arrange
        let keyId = "#mockKeyId"
        let did = "did:test:mock"
        let credentialIssuer = "credentialIssuer"
        let validTime = (Date().timeIntervalSince1970).rounded(.down)
        let mockDocumentResolver = MockIdentifierDocumentResolver(mockResolve: createMockResolve(keyId))
        let mockRootOfTrustResolver = MockRootOfTrustResolver()
        let processor = SignedCredentialMetadataProcessor(tokenVerifier: TokenVerifier(),
                                                          identifierDocumentResolver:mockDocumentResolver,
                                                          rootOfTrustResolver: mockRootOfTrustResolver)
        
        let metadataTokenClaims = SignedMetadataTokenClaims(sub: "invalidSub",
                                                            iss: "invalidIssuer",
                                                            exp: validTime,
                                                            iat: validTime)
        
        let signedMetadata = SignedMetadata(headers: Header(keyId: "\(did)\(keyId)"),
                                                     content: metadataTokenClaims)!
        let serializedMetadata = try signedMetadata.serialize()
        
        do
        {
            // Act
            let _ = try await processor.process(signedMetadata: serializedMetadata,
                                                credentialIssuer: credentialIssuer)
        }
        catch
        {
            // Assert
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "signed_metadata_token_malformed")
            XCTAssertEqual(validationError.message, "Signed metadata is not valid.")
            XCTAssert(validationError.error is TokenValidationError)
            let tokenError = validationError.error as! TokenValidationError
            XCTAssertEqual(tokenError.code, "invalid_property")
            XCTAssertEqual(tokenError.message, "Invalid String for property: iss. Expected: did:test:mock, Actual: invalidIssuer.")
            
        }
    }
    
    func testProcess_WithSignatureFailed_ThrowsError() async throws
    {
        // Arrange
        let keyId = "#mockKeyId"
        let did = "did:test:mock"
        let credentialIssuer = "credentialIssuer"
        let validTime = (Date().timeIntervalSince1970).rounded(.down)
        let mockDocumentResolver = MockIdentifierDocumentResolver(mockResolve: createMockResolve(keyId))
        let mockRootOfTrustResolver = MockRootOfTrustResolver()
        let mockTokenVerifier = MockTokenVerifier(isTokenValid: false)
        let processor = SignedCredentialMetadataProcessor(tokenVerifier: mockTokenVerifier,
                                                          identifierDocumentResolver:mockDocumentResolver,
                                                          rootOfTrustResolver: mockRootOfTrustResolver)
        
        let metadataTokenClaims = SignedMetadataTokenClaims(sub: credentialIssuer, 
                                                            iss: did,
                                                            exp: validTime, 
                                                            iat: validTime)
        
        let signedMetadata = SignedMetadata(headers: Header(keyId: "\(did)\(keyId)"),
                                                     content: metadataTokenClaims)!
        let serializedMetadata = try signedMetadata.serialize()
        
        do
        {
            // Act
            let _ = try await processor.process(signedMetadata: serializedMetadata,
                                                credentialIssuer: credentialIssuer)
        }
        catch
        {
            // Assert
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "signed_metadata_token_malformed")
            XCTAssertEqual(validationError.message, "Signed metadata is not valid.")
            XCTAssert(validationError.error is TokenValidationError)
            let tokenError = validationError.error as! TokenValidationError
            XCTAssertEqual(tokenError.code, "signature_invalid")
            XCTAssertEqual(tokenError.message, "Signature is not valid.")
        }
    }
    
    func testProcess_WithRootOfTrustResolverFails_ThrowsError() async throws
    {
        // Arrange
        let keyId = "#mockKeyId"
        let did = "did:test:mock"
        let credentialIssuer = "credentialIssuer"
        let validTime = (Date().timeIntervalSince1970).rounded(.down)
        let mockDocumentResolver = MockIdentifierDocumentResolver(mockResolve: createMockResolve(keyId))
        let mockRootOfTrustResolver = MockRootOfTrustResolver(shouldThrowError: true)
        let mockTokenVerifier = MockTokenVerifier(isTokenValid: true)
        let processor = SignedCredentialMetadataProcessor(tokenVerifier: mockTokenVerifier,
                                                          identifierDocumentResolver:mockDocumentResolver,
                                                          rootOfTrustResolver: mockRootOfTrustResolver)
        
        let metadataTokenClaims = SignedMetadataTokenClaims(sub: credentialIssuer,
                                                            iss: did,
                                                            exp: validTime,
                                                            iat: validTime)
        
        let signedMetadata = SignedMetadata(headers: Header(keyId: "\(did)\(keyId)"),
                                                     content: metadataTokenClaims)!
        let serializedMetadata = try signedMetadata.serialize()
        
        do
        {
            // Act
            let _ = try await processor.process(signedMetadata: serializedMetadata,
                                                credentialIssuer: credentialIssuer)
        }
        catch
        {
            // Assert
            XCTAssert(error is MockRootOfTrustResolver.ExpectedError)
        }
    }
    
    func testProcess_WithAllValidationPasses_ReturnsRootOfTrust() async throws
    {
        // Arrange
        let keyId = "#mockKeyId"
        let did = "did:test:mock"
        let credentialIssuer = "credentialIssuer"
        let validTime = (Date().timeIntervalSince1970).rounded(.down)
        let mockDocumentResolver = MockIdentifierDocumentResolver(mockResolve: createMockResolve(keyId))
        let mockRootOfTrustResolver = MockRootOfTrustResolver()
        let mockTokenVerifier = MockTokenVerifier(isTokenValid: true)
        let processor = SignedCredentialMetadataProcessor(tokenVerifier: mockTokenVerifier,
                                                          identifierDocumentResolver:mockDocumentResolver,
                                                          rootOfTrustResolver: mockRootOfTrustResolver)
        
        let metadataTokenClaims = SignedMetadataTokenClaims(sub: credentialIssuer,
                                                            iss: did,
                                                            exp: validTime,
                                                            iat: validTime)
        
        let signedMetadata = SignedMetadata(headers: Header(keyId: "\(did)\(keyId)"),
                                            content: metadataTokenClaims)!
        let serializedMetadata = try signedMetadata.serialize()
        
        // Act
        let rootOfTrust = try await processor.process(signedMetadata: serializedMetadata,
                                                      credentialIssuer: credentialIssuer)
        
        // Assert
        XCTAssertEqual(rootOfTrust, RootOfTrust(verified: true, source: "mockSource"))
    }
    
    private func createMockResolve(_ keyId: String = "#invalidId") -> ((String) throws -> IdentifierDocument)
    {
        let secpKey = Secp256k1PublicKey(x: Data(count: 32), y: Data(count: 32))!
        let publicJwk = ECPublicJwk(withPublicKey: secpKey, withKeyId: keyId)
        let publicKey = IdentifierDocumentPublicKey(id: keyId,
                                                    type: "mock",
                                                    controller: nil,
                                                    publicKeyJwk: publicJwk,
                                                    purposes: nil)
        let document = IdentifierDocument(service: nil,
                                          verificationMethod: [publicKey],
                                          authentication: [],
                                          id: "mock document")
        
        let mockResolve = { (_: String) in
            return document
        }
        
        return mockResolve
    }
}
