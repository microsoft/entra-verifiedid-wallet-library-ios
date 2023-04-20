/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCNetworking

class SimpleSuccessHandlerTests: XCTestCase {
    
    let handler = SimpleSuccessHandler()
    var response = HTTPURLResponse()
    let expectedResponseBody = MockObject(id: "test")
    let jsonEncoder = JSONEncoder()
    let decoder = MockDecoder()

    func testHandleSuccessfulResponse() throws {
        let encodedResponseBody = try jsonEncoder.encode(expectedResponseBody)
        let actualResponseBody = try handler.onSuccess(data: encodedResponseBody, decodeWith: decoder)
        XCTAssertEqual(actualResponseBody, self.expectedResponseBody)
    }

}
