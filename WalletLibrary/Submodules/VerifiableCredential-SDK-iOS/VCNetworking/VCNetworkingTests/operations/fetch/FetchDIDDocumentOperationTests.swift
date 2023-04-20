/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import PromiseKit
import VCEntities

@testable import VCNetworking

class FetchDIDDocumentOperationTests: XCTestCase {
    private var fetchOperation: FetchDIDDocumentOperation!
    private let expectedIdentifier = "did:test:239235"
    private let expectedHttpResponse = "expectedHttpResponse324"
    
    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [UrlProtocolMock.self]
        let urlSession = URLSession.init(configuration: configuration)
        do {
            fetchOperation = try FetchDIDDocumentOperation(withIdentifier: expectedIdentifier, session: urlSession)
        } catch {
            print(error)
        }
    }
    
    func testSuccessfulInit() {
        XCTAssertTrue(fetchOperation.successHandler is SimpleSuccessHandler)
        XCTAssertTrue(fetchOperation.failureHandler is SimpleFailureHandler)
        XCTAssertTrue(fetchOperation.retryHandler is NoRetry)
        XCTAssertEqual(fetchOperation.urlRequest.url!.absoluteString, VCSDKConfiguration.sharedInstance.discoveryUrl + "/" + expectedIdentifier)
    }
}
