/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PostIssuanceResponseOperationTests: XCTestCase {
    private var postOperation: PostIssuanceResponseOperation!
    private let expectedUrl = "https://testcontract.com/4235"
    private let expectedHttpResponse = "testPresentationResponse29384"
    private let expectedRequestBody = IssuanceResponse(from: TestData.issuanceResponse.rawValue)!
    private let encoder = IssuanceResponseEncoder()
    private var expectedEncodedBody: Data!

    override func setUpWithError() throws {
        self.expectedEncodedBody = try encoder.encode(value: expectedRequestBody)

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [UrlProtocolMock.self]
        let urlSession = URLSession.init(configuration: configuration)
        postOperation = try PostIssuanceResponseOperation(usingUrl: self.expectedUrl, withBody: expectedRequestBody, urlSession: urlSession)
    }

    func testSuccessfulInit() throws {
        XCTAssertTrue(postOperation.successHandler is SimpleSuccessHandler)
        XCTAssertTrue(postOperation.failureHandler is SimpleFailureHandler)
        XCTAssertTrue(postOperation.retryHandler is NoRetry)
        XCTAssertEqual(postOperation.urlRequest.url!.absoluteString, expectedUrl)
        XCTAssertEqual(postOperation.urlRequest.url!.absoluteString, expectedUrl)
        XCTAssertEqual(postOperation.urlRequest.httpBody!, self.expectedEncodedBody)
        XCTAssertEqual(postOperation.urlRequest.httpMethod!, Constants.POST)
        XCTAssertEqual(postOperation.urlRequest.value(forHTTPHeaderField: Constants.CONTENT_TYPE)!, Constants.PLAIN_TEXT)
    }

    func testInvalidUrlInit() {
        let invalidUrl = ""
        XCTAssertThrowsError(try PostIssuanceResponseOperation(usingUrl: invalidUrl,
                                                               withBody: expectedRequestBody,
                                                               urlSession: URLSession.shared)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.invalidUrl(withUrl: invalidUrl))
        }
    }
}
