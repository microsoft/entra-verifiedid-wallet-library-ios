/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class NoRetryTests: XCTestCase {
    
    let noRetry = NoRetry()
    var expectedClosureCalled = false
    let expectedAnswer = 425

    func testNoRetry() async throws {
        let actualResult = try await noRetry.onRetry(closure: expectedClosure)
            XCTAssertEqual(actualResult, expectedAnswer)
            XCTAssertTrue(expectedClosureCalled)
    }
    
    func expectedClosure() async throws -> Int {
        expectedClosureCalled = true
        return expectedAnswer
    }

}
