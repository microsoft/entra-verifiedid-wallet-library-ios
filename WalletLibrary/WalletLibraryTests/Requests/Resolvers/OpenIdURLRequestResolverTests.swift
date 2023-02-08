/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenIdURLRequestResolverTests: XCTestCase {
    
    func testResolve_WithURLInput_ReturnRawRequest() async throws {
        
        let mockInput = VerifiedIdRequestURL(url: URL(string: "openid-vc://mock.com")!)
        let expectedRawData = "test data".data(using: .utf8)!
        let expectedRawRequest = MockOpenIdRawRequest(raw: expectedRawData)
        let mockCallback = { (url: String) in
            return expectedRawRequest
        }
        let openIdResolver = MockOpenIdForVCResolver(mockGetRequestCallback: mockCallback)
        let resolver = OpenIdURLRequestResolver(openIdResolver: openIdResolver)
        
        let actualRawRequest = try await resolver.resolve(input: mockInput)
        
        XCTAssertEqual(actualRawRequest as? MockOpenIdRawRequest, expectedRawRequest)
    }
    
    func testResolve_WithInvalidRequestInput_ThrowsError() async throws {
        
        let mockData = "test data"
        let mockInput = MockInput(mockData: mockData)
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        do {
            let _ = try await resolver.resolve(input: mockInput)
            XCTFail()
        } catch {
            XCTAssert(error is OpenIdURLRequestResolverError)
            
            switch (error as? OpenIdURLRequestResolverError) {
            case .unsupportedVerifiedIdRequestInput(type: let type):
                XCTAssertEqual(type, "MockInput")
            default:
                XCTFail()
            }
        }
    }

    func testCanResolve_WithInvalidRequestInputType_ReturnsFalse() throws {
        
        let mockInput = MockInput(mockData: "mock data")
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        let actualResult = resolver.canResolve(input: mockInput)
        
        XCTAssertFalse(actualResult)
        
    }
    
    func testCanResolve_WithInvalidRequestInputScheme_ReturnFalse() throws {
        
        let mockInput = VerifiedIdRequestURL(url: URL(string: "https://mock.com")!)
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        let actualResult = resolver.canResolve(input: mockInput)
        
        XCTAssertFalse(actualResult)
    }

    func testCanResolve_WithValidRequestInput_ReturnTrue() throws {
        
        let mockInput = VerifiedIdRequestURL(url: URL(string: "openid-vc://mock.com")!)
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        let actualResult = resolver.canResolve(input: mockInput)
        
        XCTAssertTrue(actualResult)

    }
    
    func testCanResolve_WithInvalidRequestHandler_ReturnFalse() throws {
        
        let mockHandler = MockHandler()
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        let actualResult = resolver.canResolve(using: mockHandler)
        
        XCTAssertFalse(actualResult)

    }
    
    func testCanResolve_WithValidRequestHandler_ReturnTrue() throws {

        let mockHandler = OpenIdRequestHandler()
        let resolver = OpenIdURLRequestResolver(openIdResolver: MockOpenIdForVCResolver())
        
        let actualResult = resolver.canResolve(using: mockHandler)
        
        XCTAssertTrue(actualResult)
    }
}
