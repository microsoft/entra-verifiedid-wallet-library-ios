/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenIdRequestHandlerTests: XCTestCase {
    
    enum ExpectedError: Error, Equatable {
        case expectedToBeThrown
    }
    
    func testHandleRequest_WithRawPresentationRequest_ReturnsVerifiedIdRequest() async throws {
        
        // Arrange
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = MockRequirement(id: "mockRequirement324")
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = VerifiedIdRequestContent(style: expectedStyle,
                                                       requirement: expectedRequirement,
                                                       rootOfTrust: expectedRootOfTrust)
        let mockMapper = MockMapper(returnedObject: expectedContent)
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
    
    func testHandleRequest_WithPresentationRequestInvalidMapping_ThrowsError() async throws {
        
        // Arrange
        let mockMapper = MockMapper(error: ExpectedError.expectedToBeThrown)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data())
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestHandler(configuration: configuration)
        
        // Act
        do {
            let _ = try await handler.handleRequest(from: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, ExpectedError.expectedToBeThrown)
        }
    }
}
