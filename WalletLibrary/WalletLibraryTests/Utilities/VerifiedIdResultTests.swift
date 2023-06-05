/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdResultTests: XCTestCase {
    
    enum ExpectedError: Error, Equatable {
        case expectedToBeThrown
    }
    
    func testGetResult_WithSuccess_ReturnsSuccessfulResult() async throws {
        // Arrange
        let expectedResultValue = "successful result"
        let callback = {
            return expectedResultValue
        }
        
        // Act
        let actualResult = await VerifiedIdResult<String>.getResult(callback: callback)
        
        
        //Assert
        XCTAssertEqual(try actualResult.get(), expectedResultValue)
    }
    
    func testGetResult_WithVerifiedIdError_ReturnsFailureResultWithVerifiedIdError() async throws {
        // Arrange
        let expectedError = MockVerifiedIdError()
        let callback = {
            throw expectedError
        }
        
        // Act
        let actualResult = await VerifiedIdResult<Void>.getResult(callback: callback)
        
        
        //Assert
        XCTAssert(actualResult.verifiedIdError is MockVerifiedIdError)
        XCTAssertIdentical(actualResult.verifiedIdError, expectedError)
    }
    
    func testGetResult_WithExpectedError_ReturnsFailureResultWithUnspecifiedVerifiedIdError() async throws {
        // Arrange
        let expectedError = ExpectedError.expectedToBeThrown
        let callback = {
            throw expectedError
        }
        
        // Act
        let actualResult = await VerifiedIdResult<Void>.getResult(callback: callback)
        
        
        //Assert
        XCTAssert(actualResult.verifiedIdError is UnspecifiedVerifiedIdError)
        XCTAssertEqual((actualResult.verifiedIdError as? UnspecifiedVerifiedIdError)?.error as? ExpectedError, expectedError)
    }
}
