/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCEntities

class IssuanceResponseClaimsTests: XCTestCase {
    
    func testInit() {
        let claims = IssuanceResponseClaims()
        XCTAssertNil(claims.scope)
        XCTAssertNil(claims.state)
        XCTAssertNil(claims.nonce)
        XCTAssertNil(claims.iat)
        XCTAssertNil(claims.exp)
        XCTAssertNil(claims.nbf)
        XCTAssertNil(claims.registration)
        XCTAssertEqual(claims.issuer, "https://self-issued.me")
        XCTAssertNil(claims.prompt)
    }
    
}
