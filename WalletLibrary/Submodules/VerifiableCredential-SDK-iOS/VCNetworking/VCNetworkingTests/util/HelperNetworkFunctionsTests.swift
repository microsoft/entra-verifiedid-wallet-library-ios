/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import Foundation
import PromiseKit

@testable import VCNetworking

class HelperNetworkFunctionsTests: XCTestCase {
    
    var flakeyTaskCalls = 0
    
    override func setUp() {}
    
    func testAttemptFunctionSuccess() {
        
        flakeyTaskCalls = 0
        let actualTestNum = 4
        let expec = self.expectation(description: "Fire")
        
        attempt(maximumRetryCount: 1) {
            self.flakeyTask(testNum: actualTestNum)
        }.done { num in
            XCTAssertEqual(self.flakeyTaskCalls, 1)
            print(num)
            expec.fulfill()
        }.catch { error in
            print(error)
            expec.fulfill()
            XCTFail()
        }
        
        wait(for: [expec], timeout: 10)
    }
    
    func testAttemptFunction2Retries() {
        
        flakeyTaskCalls = 0
        let actualTestNum = 5
        let expec = self.expectation(description: "Fire")
        
        attempt(maximumRetryCount: 2) {
            self.flakeyTask(testNum: actualTestNum)
        }.done { num in
            print(num)
            expec.fulfill()
            XCTFail()
        }.catch { error in
            XCTAssertEqual(self.flakeyTaskCalls, 2)
            print(error)
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 10)
    }
    
    func testAttemptFunctionNoRetries() {
        
        flakeyTaskCalls = 0
        let actualTestNum = 5
        let expec = self.expectation(description: "Fire")
        
        attempt(maximumRetryCount: 1) {
            self.flakeyTask(testNum: actualTestNum)
        }.done { num in
            print(num)
            expec.fulfill()
            XCTFail()
        }.catch { error in
            XCTAssertEqual(self.flakeyTaskCalls, 1)
            print(error)
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 10)
    }
    
    func flakeyTask(testNum: Int) -> Promise<Int> {
        self.flakeyTaskCalls = self.flakeyTaskCalls + 1
        print("adding 1 to flakey task calls")
        return Promise<Int> { seal in
            if (testNum == 4) {
                seal.fulfill(testNum)
            } else {
                seal.reject(NetworkingError.unknownNetworkingError(withBody: String(testNum), statusCode: 500))
            }
        }
    }
}
