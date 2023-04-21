/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class ExchangeRequestEncoderTests: XCTestCase {
    
    let expectedToken = ExchangeRequest(from: VCNetworkingTestData.exchangeRequest.rawValue)!
    let encoder = ExchangeRequestEncoder()
    
    func testEncoding() throws {
        let actualEncodedResponse = try encoder.encode(value: expectedToken)
        let expectedEncodedResponse = try expectedToken.serialize().data(using: .utf8)!
        XCTAssertEqual(actualEncodedResponse, expectedEncodedResponse)
    }
}
