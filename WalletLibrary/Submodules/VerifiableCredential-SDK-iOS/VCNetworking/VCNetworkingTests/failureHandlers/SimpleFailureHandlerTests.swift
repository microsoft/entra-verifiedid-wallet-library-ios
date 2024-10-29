/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class SimpleFailureHandlerTests: XCTestCase {
    
    private var handler: SimpleFailureHandler!
    private let expectedResponseBody = MockObject(id: "test")
    private var encodedResponse: Data!
    private var serializedExpectedResponse: String!
    
    override func setUpWithError() throws {
        let encoder = JSONEncoder()
        self.encodedResponse = try encoder.encode(expectedResponseBody)
        self.serializedExpectedResponse = String(data: self.encodedResponse, encoding: .utf8)!
        VCSDKLog.sharedInstance.add(consumer: DefaultVCLogConsumer())
        self.handler = SimpleFailureHandler(sdkLog: VCSDKLog.sharedInstance)
    }

    func testHandleResponse_WithFailure_ReturnsVerifiedIdError() throws
    {
        // Arrange
        let response = self.createHttpURLResponse(statusCode: 400)
        
        // Act
        let actualError = try handler.onFailure(data: self.encodedResponse, response: response)
        
        // Assert
        XCTAssert(actualError is VerifiedIdNetworkingError)
        let networkingError = actualError as! VerifiedIdNetworkingError
        XCTAssertEqual(actualError.message, "{\"id\":\"test\"}")
        XCTAssertEqual(actualError.code, "networking_error")
        XCTAssertEqual(networkingError.statusCode, 400)
    }
    
    private func createHttpURLResponse(statusCode: Int) -> HTTPURLResponse
    {
        let url = URL(string: "testUrl.com")!
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
