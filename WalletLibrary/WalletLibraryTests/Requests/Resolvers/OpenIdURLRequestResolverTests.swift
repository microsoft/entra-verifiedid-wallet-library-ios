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
    
    func testResolve_WithUt_ReturnsRawRequest() async throws {
        
        // Arrange
        let previewFeatureFlags = PreviewFeatureFlags(previewFeatureFlags: [PreviewFeatureFlags.OpenID4VCIAccessToken])
        let mockLibraryNetworking = MockLibraryNetworking(getExpectedResponseBodies: getExpectedResponseBodies)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(), 
                                                 networking: mockLibraryNetworking,
                                                 previewFeatureFlags: previewFeatureFlags)
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
    
    func getExpectedResponseBodies(_ input: Any) -> Any
    {
        switch input
        {
        case is OpenID4VCIRequestNetworkOperation.Type:
            return "test".data(using: .utf8)!
        default:
            return "Test"
        }
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
}
