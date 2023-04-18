/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import PromiseKit

@testable import VCNetworking

class NoRetryTests: XCTestCase {
    
    let noRetry = NoRetry()
    var expectedClosureCalled = false
    let expectedAnswer = 425

    func testNoRetry() throws {
        let expec = self.expectation(description: "Fire")
        noRetry.onRetry(closure: expectedClosure).done { actualNum in
            XCTAssertEqual(actualNum, self.expectedAnswer)
            XCTAssertTrue(self.expectedClosureCalled)
            expec.fulfill()
        }.catch { error in
            print(error)
            XCTFail()
        }
        
        wait(for: [expec], timeout: 5)
    }
    
    func expectedClosure() -> Promise<Int> {
        return Promise<Int> { seal in
            self.expectedClosureCalled = true
            seal.fulfill(self.expectedAnswer)
        }
    }

}
