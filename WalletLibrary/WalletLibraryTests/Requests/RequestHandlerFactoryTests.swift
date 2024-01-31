/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class RequestHandlerFactoryTests: XCTestCase {
    
    func testOneHandlerRegistered() throws {
        
        let expectedHandler = MockHandler()
        let mockResolver = MockResolver(canResolveUsingInput: true)
        
        let factory = RequestHandlerFactory(requestHandlers: [expectedHandler])
        
        let actualHandler = try factory.getHandler(from: mockResolver)
        XCTAssertIdentical(expectedHandler as AnyObject, actualHandler as AnyObject)
    }
    
    func testThreeHandlersRegistered() throws {
        
        let expectedHandler = MockHandler(mockCanHandle: true)
        let firstMockHandler = MockHandler()
        let secondMockHandler = MockHandler()

        let mockResolver = MockResolver(canResolveUsingInput: true)
        
        let factory = RequestHandlerFactory(requestHandlers: [expectedHandler, firstMockHandler, secondMockHandler])
        
        let actualHandler = try factory.getHandler(from: mockResolver)
        XCTAssertIdentical(expectedHandler as AnyObject, actualHandler as AnyObject)
    }

    func testUnsupportedHandlerRegistered() throws {
        
        let mockResolver = MockResolver(canResolveUsingInput: true)
        let mockHandler = MockHandler()
        
        let factory = RequestHandlerFactory(requestHandlers: [mockHandler])
        
        XCTAssertThrowsError(try factory.getHandler(from: mockResolver)) { error in
            XCTAssert(error is RequestHandlerFactoryError)
            XCTAssertEqual(error as? RequestHandlerFactoryError, .UnsupportedRawRequest)
        }
    }

    func testNoResolversRegistered() throws {
        
        let factory = RequestHandlerFactory(requestHandlers: [])
        let mockResolver = MockResolver(canResolveUsingInput: true)
        
        XCTAssertThrowsError(try factory.getHandler(from: mockResolver)) { error in
            XCTAssert(error is RequestHandlerFactoryError)
            XCTAssertEqual(error as? RequestHandlerFactoryError, .UnsupportedRawRequest)
        }
    }
}
