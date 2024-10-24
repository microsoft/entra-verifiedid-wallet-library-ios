/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class FetchContractTests: XCTestCase {
    private var fetchContractOperation: FetchContractOperation!
    private let expectedUrl = "https://testcontract.com/4235"
    private let expectedHttpResponse = "expectedHttpResponse324"
    
    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [UrlProtocolMock.self]
        let urlSession = URLSession.init(configuration: configuration)
        do {
            fetchContractOperation = try FetchContractOperation(withUrl: expectedUrl, session: urlSession)
        } catch {
            print(error)
        }
    }
    
    func testSuccessfulInit() {
        XCTAssertTrue(fetchContractOperation.successHandler is SimpleSuccessHandler)
        XCTAssertTrue(fetchContractOperation.failureHandler is SimpleFailureHandler)
        XCTAssertTrue(fetchContractOperation.retryHandler is NoRetry)
        XCTAssertEqual(fetchContractOperation.urlRequest.url!.absoluteString, expectedUrl)
    }
    
    func testInvalidUrlInit() {
        let invalidUrl = ""
        XCTAssertThrowsError(try FetchContractOperation(withUrl: invalidUrl, session: URLSession.shared)) { error in
            XCTAssert(error is VerifiedIdError)
            let networkingError = error as! VerifiedIdError
            XCTAssertEqual(networkingError.message, "Invalid url: .")
            XCTAssertEqual(networkingError.code, "malformed_input_error")
        }
    }
}
