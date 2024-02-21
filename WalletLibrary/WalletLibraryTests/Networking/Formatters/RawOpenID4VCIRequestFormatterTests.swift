/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class RawOpenID4VCIRequestFormatterTests: XCTestCase
{
    
    func testFormat_WithInvalidConfigIds_ThrowsError() async throws
    {
        // Arrange
        let formatter = RawOpenID4VCIRequestFormatter(signer: MockSigner(),
                                                      configuration: LibraryConfiguration())
        let mockAccessToken = "mock access token"
        let mockEndpoint = "mock endpoint"
        let mockCredentialOffer = createCredentialOffer(configIds: [])
        
        // Act / Assert
        XCTAssertThrowsError(try formatter.format(credentialOffer: mockCredentialOffer,
                                                  credentialEndpoint: mockEndpoint,
                                                  accessToken: mockAccessToken)) { error in
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "request_creation_error")
            XCTAssertEqual(validationError.message, "Configuration Id not present in Credential Offer.")
        }
    }
    
    func testFormat_WhenUnableToFetchIdentifier_ThrowsError() async throws
    {
        // Arrange
        let mockIdentifierManager = MockIdentifierManager(doesThrow: true)
        let libraryConfig = LibraryConfiguration(identifierManager: mockIdentifierManager)
        let formatter = RawOpenID4VCIRequestFormatter(signer: MockSigner(),
                                                      configuration: libraryConfig)
        let mockAccessToken = "mock access token"
        let mockEndpoint = "mock endpoint"
        let mockCredentialOffer = createCredentialOffer()
        
        // Act / Assert
        XCTAssertThrowsError(try formatter.format(credentialOffer: mockCredentialOffer,
                                                  credentialEndpoint: mockEndpoint,
                                                  accessToken: mockAccessToken)) { error in
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "request_creation_error")
            XCTAssertEqual(validationError.message, "Unable to fetch user's signing key reference.")
        }
    }
    
    func testFormat_WhenSigningThrowsError_ThrowsError() async throws
    {
        // Arrange
        let mockSigner = MockSigner(doesSignThrow: true)
        let mockIdentifierManager = MockIdentifierManager()
        let libraryConfig = LibraryConfiguration(identifierManager: mockIdentifierManager)
        let formatter = RawOpenID4VCIRequestFormatter(signer: mockSigner,
                                                      configuration: libraryConfig)
        let mockAccessToken = "mock access token"
        let mockEndpoint = "mock endpoint"
        let mockCredentialOffer = createCredentialOffer()
        
        // Act / Assert
        XCTAssertThrowsError(try formatter.format(credentialOffer: mockCredentialOffer,
                                                  credentialEndpoint: mockEndpoint,
                                                  accessToken: mockAccessToken)) { error in
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "request_creation_error")
            XCTAssertEqual(validationError.message, "Unable to format the Proof Token.")
            XCTAssertEqual(validationError.error as? MockSigner.ExpectedError,
                           MockSigner.ExpectedError.SignExpectedToThrow)
        }
    }
    
    func testFormat_WhenWithValidInput_ReturnsRequest() async throws
    {
        // Arrange
        let mockSigner = MockSigner()
        let mockIdentifierManager = MockIdentifierManager()
        let libraryConfig = LibraryConfiguration(identifierManager: mockIdentifierManager)
        let formatter = RawOpenID4VCIRequestFormatter(signer: mockSigner,
                                                      configuration: libraryConfig)
        let mockAccessToken = "mock access token"
        let mockEndpoint = "mock endpoint"
        let mockConfigurationId = "mock config id"
        let mockIssuerSession = "mock issuer session"
        let mockCredentialOffer = createCredentialOffer(configIds: [mockConfigurationId],
                                                        issuerSession: mockIssuerSession)
        
        // Act
        let request = try formatter.format(credentialOffer: mockCredentialOffer,
                                           credentialEndpoint: mockEndpoint,
                                           accessToken: mockAccessToken)
        
        // Assert
        XCTAssertEqual(request.credential_configuration_id, mockConfigurationId)
        XCTAssertEqual(request.issuer_session, mockIssuerSession)
        XCTAssertEqual(request.proof.proof_type, "jwt")
        let result = JwsToken<OpenID4VCIJWTProofClaims>(from: request.proof.jwt)
        XCTAssertEqual(result?.content.aud, mockEndpoint)
        XCTAssertEqual(result?.content.sub, "did:test:1234")
        XCTAssertEqual(result?.content.at_hash, "1EZBnvsFWlK8ESkgHQsrISKuTFVEzRM4MyM9Z7xwrDs")
    }
    
    private func createCredentialOffer(configIds: [String] = ["configIds"],
                                       issuerSession: String = "") -> CredentialOffer
    {
        return CredentialOffer(credential_issuer: "",
                               issuer_session: issuerSession,
                               credential_configuration_ids: configIds,
                               grants: [:])
    }
}
