/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCEntities

class OIDCClaimsExtensionTests: XCTestCase {

    func testInit() throws {
        let mockOidcClaims = MockOIDCClaims()
        XCTAssertNil(mockOidcClaims.responseType)
        XCTAssertNil(mockOidcClaims.responseMode)
        XCTAssertNil(mockOidcClaims.clientID)
        XCTAssertNil(mockOidcClaims.exp)
        XCTAssertNil(mockOidcClaims.iat)
        XCTAssertNil(mockOidcClaims.nbf)
        XCTAssertNil(mockOidcClaims.issuer)
        XCTAssertNil(mockOidcClaims.nonce)
        XCTAssertNil(mockOidcClaims.state)
        XCTAssertNil(mockOidcClaims.prompt)
        XCTAssertNil(mockOidcClaims.redirectURI)
        XCTAssertNil(mockOidcClaims.scope)
    }
}
