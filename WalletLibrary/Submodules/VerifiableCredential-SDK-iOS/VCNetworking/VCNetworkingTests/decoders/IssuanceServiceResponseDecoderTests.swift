/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities

@testable import VCNetworking

class IssuanceServiceResponseDecoderTests: XCTestCase {
    
    let expectedResponse = IssuanceServiceResponse(vc: TestData.verifiableCredential.rawValue)
    let expectedToken = VerifiableCredential(from: TestData.verifiableCredential.rawValue)!
    var encodedResponse: Data!
    let decoder = IssuanceServiceResponseDecoder()
    
    override func setUpWithError() throws {
        encodedResponse = try JSONEncoder().encode(expectedResponse)
    }
    
    func testDecode() throws {
        let actualResponse = try decoder.decode(data: encodedResponse)
        XCTAssertEqual(actualResponse.content.iss, expectedToken.content.iss)
        XCTAssertEqual(actualResponse.content.sub, expectedToken.content.sub)
        XCTAssertEqual(actualResponse.content.jti, expectedToken.content.jti)
    }
    
    func testThrowError() throws {
        let malFormedEncodedToken = Data(count: 64)
        XCTAssertThrowsError(try decoder.decode(data: malFormedEncodedToken))
    }

}
