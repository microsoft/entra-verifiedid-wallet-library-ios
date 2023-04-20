/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import PromiseKit

@testable import VCNetworking

class FetchWellKnownConfigDocumentOperationTests: XCTestCase {
    let expectedUrl = "https://did.com/.well-known/did-configuration.json"
    
    func testInitWithPath() throws {
        let fetchOperation = try FetchWellKnownConfigDocumentOperation(withUrl: "https://did.com/test")
        XCTAssertTrue(fetchOperation.successHandler is SimpleSuccessHandler)
        XCTAssertTrue(fetchOperation.failureHandler is SimpleFailureHandler)
        XCTAssertTrue(fetchOperation.retryHandler is NoRetry)
        XCTAssertEqual(fetchOperation.urlRequest.url!.absoluteString, expectedUrl)
    }
    
    func testInitWithTrailingSlash() throws {
        let fetchOperation = try FetchWellKnownConfigDocumentOperation(withUrl: "https://did.com/")
        XCTAssertTrue(fetchOperation.successHandler is SimpleSuccessHandler)
        XCTAssertTrue(fetchOperation.failureHandler is SimpleFailureHandler)
        XCTAssertTrue(fetchOperation.retryHandler is NoRetry)
        XCTAssertEqual(fetchOperation.urlRequest.url!.absoluteString, expectedUrl)
    }
    
    func testInitWithNoPath() throws {
        let fetchOperation = try FetchWellKnownConfigDocumentOperation(withUrl: "https://did.com")
        XCTAssertTrue(fetchOperation.successHandler is SimpleSuccessHandler)
        XCTAssertTrue(fetchOperation.failureHandler is SimpleFailureHandler)
        XCTAssertTrue(fetchOperation.retryHandler is NoRetry)
        XCTAssertEqual(fetchOperation.urlRequest.url!.absoluteString, expectedUrl)
    }
    
    func testInitWithQuery() throws {
        let fetchOperation = try FetchWellKnownConfigDocumentOperation(withUrl: "https://did.com?idToken=abcd")
        XCTAssertTrue(fetchOperation.successHandler is SimpleSuccessHandler)
        XCTAssertTrue(fetchOperation.failureHandler is SimpleFailureHandler)
        XCTAssertTrue(fetchOperation.retryHandler is NoRetry)
        XCTAssertEqual(fetchOperation.urlRequest.url!.absoluteString, expectedUrl)
    }
    
    
}
