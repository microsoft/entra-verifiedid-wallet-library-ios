/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import XCTest

@testable import WalletLibrary

class NetworkOperationTests: XCTestCase {
    private var mockNetworkOperation: MockNetworkOperation!
    private let expectedUrl = "https://testcontract.com/4235"
    private let expectedHttpResponse = MockObject(id: "test")
    private var serializedExpectedResponse: String!
    
    override func setUpWithError() throws {
        self.mockNetworkOperation = MockNetworkOperation()
        let encodedResponse = try JSONEncoder().encode(expectedHttpResponse)
        self.serializedExpectedResponse = String(data: encodedResponse, encoding: .utf8)!
    }
    
    func testSuccessfulFetchOperation() async throws {
        // Arrange
        try UrlProtocolMock.createMockResponse(httpResponse: self.expectedHttpResponse, url: expectedUrl, statusCode: 200)
        
        // Act
        let response = try await self.mockNetworkOperation.fire()
        
        // Assert
        XCTAssertEqual(response, expectedHttpResponse)
    }
    
    func testFailedFetchOperationBadRequestBody() async throws {
        // Arrange
        try UrlProtocolMock.createMockResponse(httpResponse: self.expectedHttpResponse, url: expectedUrl, statusCode: 400)
        
        do {
            // Act
            let response = try await self.mockNetworkOperation.fire()
            XCTFail()
        } catch {
            // Assert
            XCTAssertEqual(error as! NetworkingError, NetworkingError.badRequest(withBody: self.serializedExpectedResponse, statusCode: 400))
        }
    }
}
