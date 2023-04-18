/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities

@testable import VCNetworking

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

    func testHandleResponseFailureBadRequest() throws {
        let response = self.createHttpURLResponse(statusCode: 400)
        let actualError = try handler.onFailure(data: self.encodedResponse, response: response)
        XCTAssertEqual(actualError, NetworkingError.badRequest(withBody: serializedExpectedResponse, statusCode: 400))
    }
    
    func testHandleResponseFailureUnauthorized() throws {
        let response = self.createHttpURLResponse(statusCode: 401)
        let actualError = try handler.onFailure(data: encodedResponse, response: response)
        XCTAssertEqual(actualError, NetworkingError.unauthorized(withBody: serializedExpectedResponse, statusCode: 401))
    }
    
    func testHandleResponseFailureForbidden() throws {
        let response = self.createHttpURLResponse(statusCode: 403)
        let actualError = try handler.onFailure(data: encodedResponse, response: response)
        XCTAssertEqual(actualError, NetworkingError.forbidden(withBody: serializedExpectedResponse, statusCode: 403))
    }
    
    func testHandleResponseFailureNotFound() throws {
        let response = self.createHttpURLResponse(statusCode: 404)
        let actualError = try handler.onFailure(data: encodedResponse, response: response)
        XCTAssertEqual(actualError, NetworkingError.notFound(withBody: serializedExpectedResponse, statusCode: 404))
    }
    
    func testHandleResponseFailureServiceError() throws {
        let response = self.createHttpURLResponse(statusCode: 500)
        let actualError = try handler.onFailure(data: encodedResponse, response: response)
        XCTAssertEqual(actualError, NetworkingError.serverError(withBody: serializedExpectedResponse, statusCode: 500))
    }
    
    func testHandleResponseFailureUnknownError() throws {
        let response = self.createHttpURLResponse(statusCode: 600)
        let actualError = try handler.onFailure(data: encodedResponse, response: response)
        XCTAssertEqual(actualError, NetworkingError.unknownNetworkingError(withBody: serializedExpectedResponse, statusCode: 600))
    }
    
    private func createHttpURLResponse(statusCode: Int) -> HTTPURLResponse {
        let url = URL(string: "testUrl.com")!
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

}
