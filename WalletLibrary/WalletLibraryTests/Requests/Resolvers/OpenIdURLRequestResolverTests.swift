/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenIdURLRequestResolverTests: XCTestCase {
    
    func testResolve_WithURLInput_ReturnsRawRequest() async throws {
        
        // Arrange
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        let mockInput = VerifiedIdRequestURL(url: URL(string: "openid-vc://mock.com")!)
        let expectedRawData = "test data".data(using: .utf8)!
        let expectedRawRequest = MockOpenIdRawRequest(raw: expectedRawData)
        let mockCallback = { (url: String) in
            return expectedRawRequest
        }
        let openIdResolver = MockOpenIdForVCResolver(mockGetRequestCallback: mockCallback)
        let resolver = OpenIdURLRequestResolver(openIdResolver: openIdResolver, configuration: configuration)
        
        // Act
        let actualRawRequest = try await resolver.resolve(input: mockInput)
        
        // Assert
        XCTAssertEqual(actualRawRequest as? MockOpenIdRawRequest, expectedRawRequest)
    }
    
    func testResolveOpenId4VCI_WithMalformedURLInput_ThrowsError() async throws {
        
        // Arrange
        let previewFeatureFlags = PreviewFeatureFlags(previewFeatureFlags: [PreviewFeatureFlags.OpenID4VCIAccessToken])
        let mockLibraryNetworking = MockLibraryNetworking.expectToThrow()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(), 
                                                 networking: mockLibraryNetworking,
                                                 previewFeatureFlags: previewFeatureFlags)
        
        let mockURL = "openid-vc://mock.com"
        let mockInput = VerifiedIdRequestURL(url: URL(string: mockURL)!)

        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver(), configuration: configuration)
        
        do
        {
            // Act
            let _ = try await resolver.resolve(input: mockInput)
            XCTFail("Should have thrown error")
        }
        catch
        {
            // Assert
            XCTAssert(error is OpenIdURLRequestResolverError)
            switch error as? OpenIdURLRequestResolverError
            {
            case .URLDoesNotContainProperQueryItem(let actualURL):
                XCTAssertEqual(mockURL, actualURL)
            default:
                XCTFail("Unexpected error type thrown")
            }
        }
    }
    
    func testResolveOpenId4VCI_WithNetworkError_ThrowsError() async throws {
        
        // Arrange
        let previewFeatureFlags = PreviewFeatureFlags(previewFeatureFlags: [PreviewFeatureFlags.OpenID4VCIAccessToken])
        let mockLibraryNetworking = MockLibraryNetworking.expectToThrow()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(),
                                                 networking: mockLibraryNetworking,
                                                 previewFeatureFlags: previewFeatureFlags)
        
        let mockURL = "openid-vc://mock.com/?request_uri=https://mock.com"
        let mockInput = VerifiedIdRequestURL(url: URL(string: mockURL)!)

        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver(), configuration: configuration)
        
        do
        {
            // Act
            let _ = try await resolver.resolve(input: mockInput)
            XCTFail("Should have thrown error")
        }
        catch
        {
            // Assert
            XCTAssert(error is MockLibraryNetworkingError)
            XCTAssertEqual(error as? MockLibraryNetworkingError, .ExpectedError)
        }
    }
    
    func testResolveOpenId4VCI_WithRequestURI_ReturnsDictionary() async throws {
        
        // Arrange
        let previewFeatureFlags = PreviewFeatureFlags(previewFeatureFlags: [PreviewFeatureFlags.OpenID4VCIAccessToken])
        let expectedResponseBody = try JSONEncoder().encode(getTestCredentialOffering())
        let expectedNetworkResult = (expectedResponseBody, OpenID4VCIRequestNetworkOperation.self)
        let mockLibraryNetworking = MockLibraryNetworking.create(expectedResults: [expectedNetworkResult])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(),
                                                 networking: mockLibraryNetworking,
                                                 previewFeatureFlags: previewFeatureFlags)
        
        let mockURL = "openid-vc://mock.com/?request_uri=https://mock.com"
        let mockInput = VerifiedIdRequestURL(url: URL(string: mockURL)!)

        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver(), configuration: configuration)
        
        // Act
        let actualRawRequest = try await resolver.resolve(input: mockInput)
        
        // Assert
        XCTAssertEqual(actualRawRequest as? [String: String], getTestCredentialOffering())
    }
    
    func testResolveOpenId4VCI_WithCredentialOfferURI_ReturnsDictionary() async throws {
        
        // Arrange
        let previewFeatureFlags = PreviewFeatureFlags(previewFeatureFlags: [PreviewFeatureFlags.OpenID4VCIAccessToken])
        let expectedResponseBody = try JSONEncoder().encode(getTestCredentialOffering())
        let expectedNetworkResult = (expectedResponseBody, OpenID4VCIRequestNetworkOperation.self)
        let mockLibraryNetworking = MockLibraryNetworking.create(expectedResults: [expectedNetworkResult])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(),
                                                 networking: mockLibraryNetworking,
                                                 previewFeatureFlags: previewFeatureFlags)
        
        let mockURL = "openid-vc://mock.com/?credential_offer_uri=https://mock.com"
        let mockInput = VerifiedIdRequestURL(url: URL(string: mockURL)!)

        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver(), configuration: configuration)
        
        // Act
        let actualRawRequest = try await resolver.resolve(input: mockInput)
        
        // Assert
        XCTAssertEqual(actualRawRequest as? [String: String], getTestCredentialOffering())
    }
    
    func testOpenId4VCI_WithPresentationToken_ReturnsOpenIdRawRequest() async throws {
        
        // Arrange
        let previewFeatureFlags = PreviewFeatureFlags(previewFeatureFlags: [PreviewFeatureFlags.OpenID4VCIAccessToken])
        let expectedNetworkResults = ("mockToken".data(using: .utf8), OpenID4VCIRequestNetworkOperation.self)
        let mockLibraryNetworking = MockLibraryNetworking.create(expectedResults: [expectedNetworkResults])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(),
                                                 networking: mockLibraryNetworking,
                                                 previewFeatureFlags: previewFeatureFlags)
        let mockInput = VerifiedIdRequestURL(url: URL(string: "openid-vc://mock.com/?credential_offer_uri=https://mock.com")!)
        let expectedRawData = "test data".data(using: .utf8)!
        let expectedRawRequest = MockOpenIdRawRequest(raw: expectedRawData)
        let mockCallback = { (url: String) in
            return expectedRawRequest
        }
        let openIdResolver = MockOpenIdForVCResolver(mockGetRequestCallback: mockCallback)
        let resolver = OpenIdURLRequestResolver(openIdResolver: openIdResolver, configuration: configuration)
        
        // Act
        let actualRawRequest = try await resolver.resolve(input: mockInput)
        
        // Assert
        XCTAssertEqual(actualRawRequest as? MockOpenIdRawRequest, expectedRawRequest)
    }
    
    func testResolve_WithInvalidRequestInput_ThrowsError() async throws {
        
        // Arrange
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        let mockData = "test data"
        let mockInput = MockInput(mockData: mockData)
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver(), configuration: configuration)
        
        // Act
        do {
            let _ = try await resolver.resolve(input: mockInput)
            XCTFail("resolver did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is OpenIdURLRequestResolverError)
            
            switch (error as? OpenIdURLRequestResolverError) {
            case .UnsupportedVerifiedIdRequestInputWith(type: let type):
                XCTAssertEqual(type, "MockInput")
            default:
                XCTFail("error thrown is incorrect type.")
            }
        }
    }

    func testCanResolve_WithInvalidRequestInputType_ReturnsFalse() throws {
        
        // Arrange
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        let mockInput = MockInput(mockData: "mock data")
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver(), configuration: configuration)
        
        // Act
        let actualResult = resolver.canResolve(input: mockInput)
        
        // Assert
        XCTAssertFalse(actualResult)
    }
    
    func testCanResolve_WithInvalidRequestInputScheme_ReturnsFalse() throws {
        
        // Arrange
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://mock.com")!)
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver(), configuration: configuration)
        
        // Act
        let actualResult = resolver.canResolve(input: mockInput)
        
        // Assert
        XCTAssertFalse(actualResult)
    }

    func testCanResolve_WithValidRequestInput_ReturnsTrue() throws {
        
        // Arrange
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        let mockInput = VerifiedIdRequestURL(url: URL(string: "openid-vc://mock.com")!)
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver(), configuration: configuration)
        
        // Act
        let actualResult = resolver.canResolve(input: mockInput)
        
        // Assert
        XCTAssertTrue(actualResult)
    }
    
    private func getTestCredentialOffering() -> [String: String]
    {
        return ["credentialOffering": "testData", "mock": "1"]
    }
}
