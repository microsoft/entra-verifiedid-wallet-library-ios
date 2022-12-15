/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import PromiseKit
@testable import WalletLibrary

private enum AsyncWrapperTestsError: Error {
    case testCaseThrowsError
}

class AsyncWrapperTests: XCTestCase {
    
    private let asyncWrapper = AsyncWrapper()
    
    private let expectedResult = "expected1243"
    
    private func testCase(input: String) -> Promise<String> {
        return Promise.value(input)
    }
    
    private func errorThrowingTestCase(input: String) -> Promise<String> {
        return Promise(error: AsyncWrapperTestsError.testCaseThrowsError)
    }

    func testSuccessfulWrapping() async throws {
        
        let actualResult = try await asyncWrapper.wrap { () in
            self.testCase(input: self.expectedResult)
        }()
        
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testWrappingThrowsError() async throws {
        
        let wrappedFunction = asyncWrapper.wrap { () in
            self.errorThrowingTestCase(input: self.expectedResult)
        }
        do {
            let result = try await wrappedFunction()
            XCTFail(result)
        } catch {
            XCTAssertEqual(error as? AsyncWrapperTestsError, AsyncWrapperTestsError.testCaseThrowsError)
        }
    }
}
