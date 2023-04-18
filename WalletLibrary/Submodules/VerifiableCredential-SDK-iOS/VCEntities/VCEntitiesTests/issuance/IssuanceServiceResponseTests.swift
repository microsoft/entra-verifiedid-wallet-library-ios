/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCEntities

class IssuanceServiceResponseTests: XCTestCase {

    func testInit() throws {
        let expectedVc = "expectedVc235"
        let serializedVc = "{\"vc\":\"\(expectedVc)\"}".data(using: .utf8)!
        let actualServiceResponse = try JSONDecoder().decode(IssuanceServiceResponse.self, from: serializedVc)
        let expectedServiceResponse = IssuanceServiceResponse(vc: expectedVc)
        XCTAssertEqual(actualServiceResponse.vc, expectedServiceResponse.vc)
        
    }
}
