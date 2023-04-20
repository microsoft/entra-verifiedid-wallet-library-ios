/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

import XCTest
@testable import VCCrypto

class Sha512Tests: XCTestCase {
    func testUtf() throws {
        runTest(for: Utf8TestData.hello.rawValue,
                expecting: "9692aa101d491e5c8239ee7ced8155aef2c5b785e5b40ebbb486a85b000cf02125339f7e12a0359fa8913271ed06f10216d44c6de6d1830ff16ed2b0a183ece2")
    }
    
    func testSingleLetter() throws {
        runTest(for: Utf8TestData.letter.rawValue,
                expecting: "1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f5302860c652bf08d560252aa5e74210546f369fbbbce8c12cfc7957b2652fe9a75")
    }
    
    func testLongUtf() throws {
        runTest(for: Utf8TestData.longString.rawValue,
                expecting: "29cd6fcf67f8c4935ae68bc04ff7736c57e7e873d389c7efe2f1a117f725908b68fd4f2d37a4e285d04eb345ac05bcdc562b5d83d3886c607b4b99f7b79b8c2a")
    }
    
    private func runTest(for message: String, expecting expected: String) {
        let expectedResult = Data(hexString:expected)
        
        let sha = Sha512()
        let result = sha.hash(data: message.data(using: .utf8)!)
        XCTAssertEqual(result, expectedResult)
    }
}
