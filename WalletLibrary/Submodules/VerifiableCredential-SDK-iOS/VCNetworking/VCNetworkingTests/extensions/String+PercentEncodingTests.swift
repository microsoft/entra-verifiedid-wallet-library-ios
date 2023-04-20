/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCNetworking

class StringTests: XCTestCase {
    
    func testNormalString() throws {
        let actualString = "https://test.com/xyz"
        XCTAssertEqual(actualString, actualString.stringByAddingPercentEncodingForRFC3986()!)
    }
    
    func testStringWithSpaces() throws {
        let actualString = "https://test.com/x y z"
        XCTAssertEqual(actualString.stringByAddingPercentEncodingForRFC3986()!, "https://test.com/x%20y%20z")
    }
    
    func testAlreadyPercentEncodedString() throws {
        let actualString = "https://test.com/x%20y%20z"
        XCTAssertEqual(actualString.stringByAddingPercentEncodingForRFC3986()!, "https://test.com/x%20y%20z")
    }
}
