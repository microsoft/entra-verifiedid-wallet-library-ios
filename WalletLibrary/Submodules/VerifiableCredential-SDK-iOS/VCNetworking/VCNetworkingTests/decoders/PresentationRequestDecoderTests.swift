/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities

@testable import VCNetworking

class PresentationRequestDecoderTests: XCTestCase {
    
    var expectedRequest: PresentationRequest!
    var encodedContract: Data!
    let decoder = PresentationRequestDecoder()
    
    func testDecode() throws {
        let expectedRequest = PresentationRequestToken(from: TestData.presentationRequest.rawValue)
        let actualRequest = try decoder.decode(data: TestData.presentationRequest.rawValue.data(using: .utf8)!)
        XCTAssertEqual(actualRequest.content, expectedRequest?.content)
    }
    
    func testThrowErrorUnableToDecodeToken() throws {
        XCTAssertThrowsError(try decoder.decode(data: Data(count: 10))) { error in
            XCTAssert(error is DecodingError)
        }
    }

}

