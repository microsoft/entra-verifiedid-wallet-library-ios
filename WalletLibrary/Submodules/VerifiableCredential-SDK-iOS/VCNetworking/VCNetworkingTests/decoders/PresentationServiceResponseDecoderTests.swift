/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities

@testable import VCNetworking

class PresentationServiceResponseDecoderTests: XCTestCase {
    
    let decoder = PresentationServiceResponseDecoder()
    
    func testDecode() throws {
        let actualResponse = try decoder.decode(data: Data(count: 10))
        XCTAssertNil(actualResponse)
    }
}
