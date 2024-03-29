/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenId4VCIProcessorTests: XCTestCase 
{
    func testCanProcess_WithInvalidRawRequest_ReturnsFalse() async throws
    {
        // Arrange
        let invalidRawRequest = "invalid raw request"
        let configuration = LibraryConfiguration()
        let handler = OpenId4VCIProcessor(configuration: configuration)
        
        // Act / Assert
        XCTAssertFalse(handler.canProcess(rawRequest: invalidRawRequest))
    }
    
    func testCanProcess_WithInvalidJSONRequest_ReturnsFalse() async throws
    {
        // Arrange
        let invalidRawRequest = ["invalid": "request"]
        let configuration = LibraryConfiguration()
        let handler = OpenId4VCIProcessor(configuration: configuration)
        
        // Act / Assert
        XCTAssertFalse(handler.canProcess(rawRequest: invalidRawRequest))
    }
    
    func testCanProcess_WithValidJSONRequest_ReturnsTrue() async throws
    {
        // Arrange
        let rawRequest = createJSONCredentialOffer()
        let configuration = LibraryConfiguration()
        let handler = OpenId4VCIProcessor(configuration: configuration)
        
        // Act / Assert
        XCTAssert(handler.canProcess(rawRequest: rawRequest))
    }
    
    func testProcess_WithInvalidRawRequest_ThrowsError() async throws
    {
        // Arrange
        let invalidRawRequest = "invalid raw request"
        let configuration = LibraryConfiguration()
        let handler = OpenId4VCIProcessor(configuration: configuration)
        
        do
        {
            // Act
            let _ = try await handler.process(rawRequest: invalidRawRequest)
        }
        catch
        {
            // Assert
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "credential_metadata_malformed")
            XCTAssertEqual(validationError.message, "Request is not in the correct format.")
        }
    }
    
    func testProcess_WithCredentialMetadataNetworkIssue_ThrowsError() async throws
    {
        // Arrange
        let rawRequest = createJSONCredentialOffer()
        let mockNetworking = MockLibraryNetworking.expectToThrow()
        let configuration = LibraryConfiguration(networking: mockNetworking)
        let handler = OpenId4VCIProcessor(configuration: configuration)
        
        do
        {
            // Act
            let _ = try await handler.process(rawRequest: rawRequest)
        }
        catch
        {
            // Assert
            XCTAssert(error is MockLibraryNetworkingError)
            XCTAssertEqual(error as? MockLibraryNetworkingError, .ExpectedError)
        }
    }
    
    func testProcess_WithInvalidConfigIds_ThrowsError() async throws
    {
        // Arrange
        let rawRequest = createJSONCredentialOffer()
        let metadata = createCredentialMetadata(expectedConfigIds: ["mismatchedCredentialId"])
        let expectedResult = (metadata, CredentialMetadataFetchOperation.self)
        let mockNetworking = MockLibraryNetworking.create(expectedResults: [expectedResult])
        let configuration = LibraryConfiguration(networking: mockNetworking)
        let handler = OpenId4VCIProcessor(configuration: configuration)
        
        do
        {
            // Act
            let _ = try await handler.process(rawRequest: rawRequest)
        }
        catch
        {
            // Assert
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "credential_metadata_malformed")
            XCTAssertEqual(validationError.message, "Request does not contain expected credential configuration.")
        }
    }
    
    func testProcess_WithMismatchedAuthServers_ThrowsError() async throws
    {
        // Arrange
        let rawRequest = createJSONCredentialOffer()
        let metadata = createCredentialMetadata(authorizationServer: "mismatchedAuthServer")
        let expectedResult = (metadata, CredentialMetadataFetchOperation.self)
        let mockNetworking = MockLibraryNetworking.create(expectedResults: [expectedResult])
        let configuration = LibraryConfiguration(networking: mockNetworking)
        let handler = OpenId4VCIProcessor(configuration: configuration)
        
        do
        {
            // Act
            let _ = try await handler.process(rawRequest: rawRequest)
        }
        catch
        {
            // Assert
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "credential_metadata_malformed")
            XCTAssertEqual(validationError.message, "Authorization servers in Credential Metadata does not contain https://login.microsoft.com")
        }
    }
    
    func testProcess_WithSignedMetadataProcessorError_ThrowsError() async throws
    {
        // Arrange
        let rawRequest = createJSONCredentialOffer()
        let metadata = createCredentialMetadata()
        
        let expectedResult = (metadata, CredentialMetadataFetchOperation.self)
        let mockNetworking = MockLibraryNetworking.create(expectedResults: [expectedResult])
        let configuration = LibraryConfiguration(networking: mockNetworking)
        
        let processor = MockSignedMetadataProcessor(shouldThrow: true)
        
        let handler = OpenId4VCIProcessor(configuration: configuration,
                                        signedMetadataProcessor: processor)
        
        do
        {
            // Act
            let _ = try await handler.process(rawRequest: rawRequest)
        }
        catch
        {
            // Assert
            XCTAssert(error is MockSignedMetadataProcessor.MockError)
            XCTAssertEqual(error as? MockSignedMetadataProcessor.MockError, .ErrorExpected)
        }
    }
    
    func testProcess_WithNoScopeValue_ReturnsVerifiedId() async throws
    {
        // Arrange
        let rawRequest = createJSONCredentialOffer()
        let metadata = createCredentialMetadata(scope: nil)
        
        let expectedResult = (metadata, CredentialMetadataFetchOperation.self)
        let mockNetworking = MockLibraryNetworking.create(expectedResults: [expectedResult])
        let configuration = LibraryConfiguration(networking: mockNetworking)
        
        let processor = MockSignedMetadataProcessor(shouldThrow: false)
        
        let handler = OpenId4VCIProcessor(configuration: configuration,
                                        signedMetadataProcessor: processor)
        
        do
        {
            // Act
            let _ = try await handler.process(rawRequest: rawRequest)
        }
        catch
        {
            // Assert
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.code, "credential_metadata_malformed")
            XCTAssertEqual(validationError.message, "Credential Configuration does not contain scope value.")
        }
    }
    
    func testProcess_WithRawRequest_ReturnsVerifiedId() async throws
    {
        // Arrange
        let rawRequest = createJSONCredentialOffer()
        let metadata = createCredentialMetadata()
        
        let expectedResult = (metadata, CredentialMetadataFetchOperation.self)
        let mockNetworking = MockLibraryNetworking.create(expectedResults: [expectedResult])
        let configuration = LibraryConfiguration(networking: mockNetworking)
        
        let processor = MockSignedMetadataProcessor(shouldThrow: false)
        
        let handler = OpenId4VCIProcessor(configuration: configuration,
                                        signedMetadataProcessor: processor)
        
        // Act
        let request = try await handler.process(rawRequest: rawRequest)
        
        
        // Assert
        XCTAssert(request is any VerifiedIdIssuanceRequest)
        XCTAssert(request is OpenId4VCIRequest)
        XCTAssert(request.requirement is AccessTokenRequirement)
        XCTAssert(request.style is VerifiedIdManifestIssuerStyle)
        XCTAssertEqual(request.rootOfTrust, RootOfTrust(verified: true, source: ""))
        XCTAssert((request as? OpenId4VCIRequest)?.verifiedIdStyle is BasicVerifiedIdStyle)
    }
    
    private func createCredentialMetadata(expectedConfigIds: [String] = ["expectedCredentialId"],
                                          authorizationServer: String = "https://login.microsoft.com",
                                          scope: String? = "expectedScope") -> CredentialMetadata
    {
        let credentialConfigs: [String: CredentialConfiguration] = expectedConfigIds.reduce(into: [:]) { (result, id) in
            let credentialConfig = CredentialConfiguration(format: nil,
                                                           scope: scope,
                                                           cryptographic_binding_methods_supported: nil,
                                                           cryptographic_suites_supported: nil,
                                                           credential_definition: nil,
                                                           display: nil,
                                                           proof_types_supported: nil)
            return result[id] = credentialConfig
        }

        let metadata = CredentialMetadata(credential_issuer: "credentialIssuer",
                                          authorization_servers: [authorizationServer],
                                          credential_endpoint: nil,
                                          notification_endpoint: nil,
                                          signed_metadata: "eymockToken",
                                          credential_configurations_supported: credentialConfigs,
                                          display: nil)
        return metadata
    }
    
    private func createJSONCredentialOffer() -> [String: Any]
    {
        let json: [String: Any] = [
            "credential_issuer": "expectedCredentialIssuer",
            "issuer_session": "expectedIssuerSession",
            "credential_configuration_ids": ["expectedCredentialId"],
            "grants": [
                "authorization_code": [
                    "authorization_server": "https://login.microsoft.com"
                ]
            ]
        ]
        
        return json
    }
}
