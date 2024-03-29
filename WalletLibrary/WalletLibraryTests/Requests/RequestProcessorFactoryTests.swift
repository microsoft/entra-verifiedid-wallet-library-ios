/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class RequestProcessorFactoryTests: XCTestCase {
    
    func testOneHandlerRegistered() throws {
        
        let expectedHandler = MockHandler(mockCanHandle: true)
        
        let factory = RequestProcessorFactory(requestHandlers: [expectedHandler])
        
        let actualHandler = try factory.getHandler(from: "mock raw request")
        XCTAssertIdentical(expectedHandler as AnyObject, actualHandler as AnyObject)
    }
    
    func testThreeHandlersRegistered() throws {
        
        let expectedHandler = MockHandler(mockCanHandle: true)
        let firstMockHandler = MockHandler()
        let secondMockHandler = MockHandler()
        
        let factory = RequestProcessorFactory(requestHandlers: [expectedHandler, firstMockHandler, secondMockHandler])
        
        let actualHandler = try factory.getHandler(from: "mock raw request")
        XCTAssertIdentical(expectedHandler as AnyObject, actualHandler as AnyObject)
    }

    func testUnsupportedHandlerRegistered() throws {
        
        let mockHandler = MockHandler()
        
        let factory = RequestProcessorFactory(requestHandlers: [mockHandler])
        
        XCTAssertThrowsError(try factory.getHandler(from: "mock raw request")) { error in
            XCTAssert(error is VerifiedIdError)
            XCTAssertEqual((error as? VerifiedIdError)?.code, "unsupported_raw_request")
            XCTAssertEqual((error as? VerifiedIdError)?.message, "Unsupported Raw Request")
        }
    }

    func testNoResolversRegistered() throws {
        
        let factory = RequestProcessorFactory(requestHandlers: [])
        
        XCTAssertThrowsError(try factory.getHandler(from: "mock raw request")) { error in
            XCTAssert(error is VerifiedIdError)
            XCTAssertEqual((error as? VerifiedIdError)?.code, "unsupported_raw_request")
            XCTAssertEqual((error as? VerifiedIdError)?.message, "Unsupported Raw Request")
        }
    }
}
