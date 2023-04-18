/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import VCToken
import XCTest

class ClaimsTest: XCTestCase {
    
    let expectedValue = "test43"

    func testMockClaims() throws {
        let claims = MockClaims(key: expectedValue)
        XCTAssertNil(claims.iat)
        XCTAssertNil(claims.exp)
        XCTAssertNil(claims.nbf)
        XCTAssertEqual(claims.key, expectedValue)
    }
}
