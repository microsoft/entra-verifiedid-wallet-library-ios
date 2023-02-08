/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenIdURLRequestResolverTests: XCTestCase {
    
    func testResolve_WithURLInput_ReturnsRawRequest() async throws {
        
        // Arrange
        let mockInput = VerifiedIdRequestURL(url: URL(string: "openid-vc://mock.com")!)
        let expectedRawData = "test data".data(using: .utf8)!
        let expectedRawRequest = MockOpenIdRawRequest(raw: expectedRawData)
        let mockCallback = { (url: String) in
            return expectedRawRequest
        }
        let openIdResolver = MockOpenIdForVCResolver(mockGetRequestCallback: mockCallback)
        let resolver = OpenIdURLRequestResolver(openIdResolver: openIdResolver)
        
        // Act
        let actualRawRequest = try await resolver.resolve(input: mockInput)
        
        // Assert
        XCTAssertEqual(actualRawRequest as? MockOpenIdRawRequest, expectedRawRequest)
    }
    
    func testResolve_WithInvalidRequestInput_ThrowsError() async throws {
        
        // Arrange
        let mockData = "test data"
        let mockInput = MockInput(mockData: mockData)
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        // Act
        do {
            let _ = try await resolver.resolve(input: mockInput)
            XCTFail("resolver did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is OpenIdURLRequestResolverError)
            
            switch (error as? OpenIdURLRequestResolverError) {
            case .unsupportedVerifiedIdRequestInputWith(type: let type):
                XCTAssertEqual(type, "MockInput")
            default:
                XCTFail("error thrown is incorrect type.")
            }
        }
    }

    func testCanResolve_WithInvalidRequestInputType_ReturnsFalse() throws {
        
        // Arrange
        let mockInput = MockInput(mockData: "mock data")
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        // Act
        let actualResult = resolver.canResolve(input: mockInput)
        
        // Assert
        XCTAssertFalse(actualResult)
    }
    
    func testCanResolve_WithInvalidRequestInputScheme_ReturnsFalse() throws {
        
        // Arrange
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://mock.com")!)
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        // Act
        let actualResult = resolver.canResolve(input: mockInput)
        
        // Assert
        XCTAssertFalse(actualResult)
    }

    func testCanResolve_WithValidRequestInput_ReturnsTrue() throws {
        
        // Arrange
        let mockInput = VerifiedIdRequestURL(url: URL(string: "openid-vc://mock.com")!)
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        // Act
        let actualResult = resolver.canResolve(input: mockInput)
        
        // Assert
        XCTAssertTrue(actualResult)
    }
    
    func testCanResolve_WithInvalidRequestHandler_ReturnsFalse() throws {
        
        // Arrange
        let mockHandler = MockHandler()
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        // Act
        let actualResult = resolver.canResolve(using: mockHandler)
        
        // Assert
        XCTAssertFalse(actualResult)
    }
    
    func testCanResolve_WithValidRequestHandler_ReturnsTrue() throws {

        // Arrange
        let mockHandler = OpenIdRequestHandler()
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        // Act
        let actualResult = resolver.canResolve(using: mockHandler)
        
        // Assert
        XCTAssertTrue(actualResult)
    }
}
