/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import PromiseKit
import VCEntities
import VCToken

@testable import VCNetworking

class PostPresentionResponseOperationTests: XCTestCase {
    private var postOperation: PostPresentationResponseOperation!
    private let expectedUrl = "https://testcontract.com/4235"
    private let expectedHttpResponse = "testPresentationResponse29384"
    private let encoder = PresentationResponseEncoder()
    private var expectedPresentationResponse: PresentationResponse!

    override func setUpWithError() throws {
        let header = Header(type: "type", algorithm: "alg", jsonWebKey: "key", keyId: "kid")
        let claims = PresentationResponseClaims(nonce: "nonce")
        let idToken = PresentationResponseToken(headers: header, content: claims)!
        let vpClaims = VerifiablePresentationClaims(verifiablePresentation: nil)
        let vpToken = VerifiablePresentation(headers: header, content: vpClaims)!
        expectedPresentationResponse = PresentationResponse(idToken: idToken, vpToken: vpToken, state: "state")

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [UrlProtocolMock.self]
        let urlSession = URLSession.init(configuration: configuration)
        postOperation = try PostPresentationResponseOperation(usingUrl: self.expectedUrl,
                                                              withBody: expectedPresentationResponse,
                                                              urlSession: urlSession)
    }

    func testSuccessfulInit() throws {
        XCTAssertTrue(postOperation.successHandler is SimpleSuccessHandler)
        XCTAssertTrue(postOperation.failureHandler is SimpleFailureHandler)
        XCTAssertTrue(postOperation.retryHandler is NoRetry)
        XCTAssertEqual(postOperation.urlRequest.url!.absoluteString, expectedUrl)
        XCTAssertEqual(postOperation.urlRequest.url!.absoluteString, expectedUrl)
        let encodedBody = try encoder.encode(value: expectedPresentationResponse)
        XCTAssertEqual(postOperation.urlRequest.httpBody!, encodedBody)
        XCTAssertEqual(postOperation.urlRequest.httpMethod!, Constants.POST)
    }

    func testInvalidUrlInit() {
        let invalidUrl = ""
        XCTAssertThrowsError(try PostPresentationResponseOperation(usingUrl: invalidUrl,
                                                                   withBody: expectedPresentationResponse)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.invalidUrl(withUrl: invalidUrl))
        }
    }
}
