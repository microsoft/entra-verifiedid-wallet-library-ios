/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class RequestHandlerFactoryTests: XCTestCase {
    
    func testOneHandlerRegistered() throws {
        
        let expectedHandler = MockHandler()
        let mockResolver = MockResolver(canResolveUsingInput: true, canResolveUsingHandler: { _ in true })
        
        let factory = RequestHandlerFactory(requestHandlers: [expectedHandler])
        
        let actualHandler = try factory.getHandler(from: mockResolver)
        XCTAssertIdentical(expectedHandler as AnyObject, actualHandler as AnyObject)
    }
    
    func testThreeHandlersRegistered() throws {
        
        let expectedHandler = MockHandler()
        let firstMockHandler = MockHandler()
        let secondMockHandler = MockHandler()
        
        let canResolveUsingHandlerMock = { (requestHandler: any RequestHandling) in
            
            if expectedHandler === requestHandler as? MockHandler {
                return true
            }
            
            return false
        }
        
        let mockResolver = MockResolver(canResolveUsingInput: true, canResolveUsingHandler: canResolveUsingHandlerMock)
        
        let factory = RequestHandlerFactory(requestHandlers: [expectedHandler, firstMockHandler, secondMockHandler])
        
        let actualHandler = try factory.getHandler(from: mockResolver)
        XCTAssertIdentical(expectedHandler as AnyObject, actualHandler as AnyObject)
    }

    func testUnsupportedHandlerRegistered() throws {
        
        let mockResolver = MockResolver(canResolveUsingInput: true, canResolveUsingHandler: { _ in false })
        let mockHandler = MockHandler()
        
        let factory = RequestHandlerFactory(requestHandlers: [mockHandler])
        
        XCTAssertThrowsError(try factory.getHandler(from: mockResolver)) { error in
            XCTAssert(error is RequestHandlerFactoryError)
            XCTAssertEqual(error as? RequestHandlerFactoryError, .UnsupportedResolver)
        }
    }

    func testNoResolversRegistered() throws {
        
        let factory = RequestHandlerFactory(requestHandlers: [])
        let mockResolver = MockResolver(canResolveUsingInput: true, canResolveUsingHandler: { _ in true })
        
        XCTAssertThrowsError(try factory.getHandler(from: mockResolver)) { error in
            XCTAssert(error is RequestHandlerFactoryError)
            XCTAssertEqual(error as? RequestHandlerFactoryError, .UnsupportedResolver)
        }
    }
}
