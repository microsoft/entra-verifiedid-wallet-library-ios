/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class RequestResolverFactoryTests: XCTestCase {
    
    private let mockData = "test data"
    
    func testOneResolverRegistered() throws {
        
        let mockInput = MockInput(mockData: mockData)
        let expectedResolver = MockResolver(canResolveUsingInput: true)
        
        let factory = RequestResolverFactory(resolvers: [expectedResolver])
        
        let actualResolver = try factory.makeResolver(from: mockInput)
        XCTAssertIdentical(expectedResolver as AnyObject, actualResolver as AnyObject)
    }
    
    func testThreeResolversRegistered() throws {
        
        let mockInput = MockInput(mockData: mockData)
        let expectedResolver = MockResolver(canResolveUsingInput: true)
        let firstMockResolver = MockResolver(canResolveUsingInput: false)
        let secondMockResolver = MockResolver(canResolveUsingInput: false)
        
        let factory = RequestResolverFactory(resolvers: [firstMockResolver, secondMockResolver, expectedResolver])
        
        let actualResolver = try factory.makeResolver(from: mockInput)
        XCTAssertIdentical(expectedResolver as AnyObject, actualResolver as AnyObject)
    }

    func testUnsupportedResolverRegistered() throws {
        
        let mockInput = MockInput(mockData: mockData)
        let mockResolver = MockResolver(canResolveUsingInput: false)
        
        let factory = RequestResolverFactory(resolvers: [mockResolver])
        
        XCTAssertThrowsError(try factory.makeResolver(from: mockInput)) { error in
            XCTAssert(error is RequestResolverFactoryError)
            XCTAssertEqual(error as? RequestResolverFactoryError, .UnsupportedInput)
        }
    }

    func testNoResolversRegistered() throws {
        
        let factory = RequestResolverFactory(resolvers: [])
        let mockInput = MockInput(mockData: mockData)
        
        XCTAssertThrowsError(try factory.makeResolver(from: mockInput)) { error in
            XCTAssert(error is RequestResolverFactoryError)
            XCTAssertEqual(error as? RequestResolverFactoryError, .UnsupportedInput)
        }
    }
}
