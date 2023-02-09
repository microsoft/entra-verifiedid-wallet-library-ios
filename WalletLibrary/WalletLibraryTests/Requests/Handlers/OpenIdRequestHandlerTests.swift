/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenIdRequestHandlerTests: XCTestCase {
    
    func testHandleRequest_WithRawRequest_ReturnsVerifiedIdPresentationRequest() async throws {
        
        // Arrange Mocked Mapper
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = MockRequirement(id: "mockRequirement324")
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = MockVerifiedIdRequestContent(style: expectedStyle,
                                                           requirement: expectedRequirement,
                                                           rootOfTrust: expectedRootOfTrust)
        let mockMapper = MockMapper(returnedObject: expectedContent)
        
        // Arrange Input
        let mockRawRequest = MockOpenIdRawRequest(raw: Data())
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestHandler(configuration: configuration)
        
        // Act
        let actualRequest = try await handler.handleRequest(from: mockRawRequest)
        
        // Assert
        XCTAssertEqual(actualRequest.style as? MockRequesterStyle, expectedStyle)
        XCTAssertEqual(actualRequest.requirement as? MockRequirement, expectedRequirement)
        XCTAssertEqual(actualRequest.rootOfTrust.source, expectedRootOfTrust.source)

    }
    
    func testHandleRequest_WithInvalidMapping_ThrowsError() async throws {
        
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
}

struct MockMapper: Mapping {
    
    let error: Error?
    
    let returnedObject: Any?
    
    init(error: Error? = nil, returnedObject: Any? = nil) {
        self.error = error
        self.returnedObject = returnedObject
    }
    
    /// Map one object to another.
    func map<T: Mappable>(_ object: T) throws -> T.T {
        
        if let error = error {
            throw error
        }
        
        if let returnedObject = returnedObject as? T.T {
            return returnedObject
        }
        
        return try object.map(using: self)
    }
}
