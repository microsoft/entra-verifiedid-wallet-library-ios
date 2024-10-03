/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenID4VCIPreAuthTokenResolverTests: XCTestCase
{
    func testResolve_WithMissingPreAuthCode_ThrowsError() async throws
    {
        // Arrange
        let configuration = LibraryConfiguration()
        let resolver = OpenID4VCIPreAuthTokenResolver(configuration: configuration)
        let grant = CredentialOfferGrant(authorization_server: "https://microsoft.com")
        
        do
        {
            // Act
            let _ = try await resolver.resolve(using: grant)
        }
        catch
        {
            // Assert
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "pre-authorized_code",
                                               in: String(describing: CredentialOfferGrant.self)))
        }
    }
    
    func testResolve_WithNetworkingError_ThrowsError() async throws
    {
        // Arrange
        let mockNetworking = MockLibraryNetworking.expectToThrow()
        let configuration = LibraryConfiguration(networking: mockNetworking)
        let resolver = OpenID4VCIPreAuthTokenResolver(configuration: configuration)
        let grant = CredentialOfferGrant(authorization_server: "https://microsoft.com",
                                         pre_authorized_code: "mockCode")
        
        do
        {
            // Act
            let _ = try await resolver.resolve(using: grant)
        }
        catch
        {
            // Assert
            XCTAssertEqual(error as? MockLibraryNetworkingError,
                           MockLibraryNetworkingError.ExpectedError)
        }
    }
    
    func testResolve_WithInvalidGrantType_ThrowsError() async throws
    {
        // Arrange
        let mockAccessToken = "mock access token"
        let expectedResponse = PreAuthTokenResponse(access_token: mockAccessToken,
                                                    token_type: nil,
                                                    time_to_live_in_seconds: nil)
        let oidcConfigResponse = OpenIDWellKnownConfiguration(issuer: "",
                                                              token_endpoint: "",
                                                              grant_types_supported: ["invalidGrantType"])
        let expectedResults: [(any Decodable, any InternalNetworkOperation.Type)] =
        [
            (expectedResponse, OpenID4VCIPreAuthTokenPostOperation.self),
            (oidcConfigResponse, OpenIDWellKnownConfigFetchOperation.self)
        ]
        let mockNetworking = MockLibraryNetworking.create(expectedResults: expectedResults)
        let configuration = LibraryConfiguration(networking: mockNetworking)
        let resolver = OpenID4VCIPreAuthTokenResolver(configuration: configuration)
        let grant = CredentialOfferGrant(authorization_server: "https://microsoft.com",
                                         pre_authorized_code: "mockCode")
        
        // Act / Assert
        do
        {
            let _ = try await resolver.resolve(using: grant)
            XCTFail()
        }
        catch
        {
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.message, "Grant type not included in well-known configuration.")
            XCTAssertEqual(validationError.code, "preauth_issuance_error")
        }
    }
    
    func testResolve_WithMissingTokenEndpoint_ThrowsError() async throws
    {
        // Arrange
        let mockAccessToken = "mock access token"
        let expectedGrantType = "urn:ietf:params:oauth:grant-type:pre-authorized_code"
        let expectedResponse = PreAuthTokenResponse(access_token: mockAccessToken,
                                                    token_type: nil,
                                                    time_to_live_in_seconds: nil)
        let oidcConfigResponse = OpenIDWellKnownConfiguration(issuer: "",
                                                              token_endpoint: nil,
                                                              grant_types_supported: [expectedGrantType])
        let expectedResults: [(any Decodable, any InternalNetworkOperation.Type)] =
        [
            (expectedResponse, OpenID4VCIPreAuthTokenPostOperation.self),
            (oidcConfigResponse, OpenIDWellKnownConfigFetchOperation.self)
        ]
        let mockNetworking = MockLibraryNetworking.create(expectedResults: expectedResults)
        let configuration = LibraryConfiguration(networking: mockNetworking)
        let resolver = OpenID4VCIPreAuthTokenResolver(configuration: configuration)
        let grant = CredentialOfferGrant(authorization_server: "https://microsoft.com",
                                         pre_authorized_code: "mockCode")
        
        // Act / Assert
        do
        {
            let _ = try await resolver.resolve(using: grant)
            XCTFail()
        }
        catch
        {
            XCTAssert(error is OpenId4VCIValidationError)
            let validationError = error as! OpenId4VCIValidationError
            XCTAssertEqual(validationError.message, "Missing token endpoint in well-known configuration.")
            XCTAssertEqual(validationError.code, "preauth_issuance_error")
        }
    }
    
    func testResolve_WithDoesNotReturnToken_ThrowsError() async throws
    {
        // Arrange
        let expectedGrantType = "urn:ietf:params:oauth:grant-type:pre-authorized_code"
        let expectedResponse = PreAuthTokenResponse(access_token: nil,
                                                    token_type: nil,
                                                    time_to_live_in_seconds: nil)
        let oidcConfigResponse = OpenIDWellKnownConfiguration(issuer: "",
                                                              token_endpoint: "https://microsoft.com",
                                                              grant_types_supported: [expectedGrantType])
        let expectedResults: [(any Decodable, any InternalNetworkOperation.Type)] =
        [
            (expectedResponse, OpenID4VCIPreAuthTokenPostOperation.self),
            (oidcConfigResponse, OpenIDWellKnownConfigFetchOperation.self)
        ]
        let mockNetworking = MockLibraryNetworking.create(expectedResults: expectedResults)
        let configuration = LibraryConfiguration(networking: mockNetworking)
        let resolver = OpenID4VCIPreAuthTokenResolver(configuration: configuration)
        let grant = CredentialOfferGrant(authorization_server: "https://microsoft.com",
                                         pre_authorized_code: "mockCode")
        
        do
        {
            // Act
            let _ = try await resolver.resolve(using: grant)
        }
        catch
        {
            // Assert
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "access_token",
                                               in: String(describing: PreAuthTokenResponse.self)))
        }
    }
    
    func testResolve_WithValidParams_ReturnsToken() async throws
    {
        // Arrange
        let mockAccessToken = "mock access token"
        let expectedGrantType = "urn:ietf:params:oauth:grant-type:pre-authorized_code"
        let expectedResponse = PreAuthTokenResponse(access_token: mockAccessToken,
                                                    token_type: nil,
                                                    time_to_live_in_seconds: nil)
        let oidcConfigResponse = OpenIDWellKnownConfiguration(issuer: "",
                                                              token_endpoint: "https://microsoft.com",
                                                              grant_types_supported: [expectedGrantType])
        let expectedResults: [(any Decodable, any InternalNetworkOperation.Type)] =
        [
            (expectedResponse, OpenID4VCIPreAuthTokenPostOperation.self),
            (oidcConfigResponse, OpenIDWellKnownConfigFetchOperation.self)
        ]
        let mockNetworking = MockLibraryNetworking.create(expectedResults: expectedResults)
        let configuration = LibraryConfiguration(networking: mockNetworking)
        let resolver = OpenID4VCIPreAuthTokenResolver(configuration: configuration)
        let grant = CredentialOfferGrant(authorization_server: "https://microsoft.com",
                                         pre_authorized_code: "mockCode")
        
        // Act
        let result = try await resolver.resolve(using: grant)
        
        // Assert
        XCTAssertEqual(result, mockAccessToken)
        
    }
}
