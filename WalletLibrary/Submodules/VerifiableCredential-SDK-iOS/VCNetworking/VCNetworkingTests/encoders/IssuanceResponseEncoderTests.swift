/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities

@testable import VCNetworking

class IssuanceResponseEncoderTests: XCTestCase {
    
    let expectedToken = IssuanceResponse(from: TestData.issuanceResponse.rawValue)!
    let encoder = IssuanceResponseEncoder()
    
    func testEncoding() throws {
        let actualEncodedResponse = try encoder.encode(value: expectedToken)
        let expectedEncodedResponse = try expectedToken.serialize().data(using: .utf8)!
        XCTAssertEqual(actualEncodedResponse, expectedEncodedResponse)
    }
}
