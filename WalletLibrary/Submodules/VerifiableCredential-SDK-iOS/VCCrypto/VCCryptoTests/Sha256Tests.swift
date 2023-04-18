/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

import XCTest
@testable import VCCrypto

class Sha256Tests: XCTestCase {
    func testUtf() throws {
        runTest(for: Utf8TestData.hello.rawValue,
                expecting: "E090D6A5A91173E9494307AE524808834AA3A1CC5CAD344DEE42A43BE7BD564B")
    }
    
    func testSingleLetter() throws {
        runTest(for: Utf8TestData.letter.rawValue,
                expecting: "CA978112CA1BBDCAFAC231B39A23DC4DA786EFF8147C4E72B9807785AFEE48BB")
    }
    
    func testLongUtf() throws {
        runTest(for: Utf8TestData.longString.rawValue,
                expecting: "BF6ED6E3D5C10D43A4C7C3DBE1A882E60C40255B68D8295A66F622908AD2C838")
    }
    
    private func runTest(for message: String, expecting expected: String) {
        let expectedResult = Data(hexString:expected)
        
        let sha = Sha256()
        let result = sha.hash(data: message.data(using: .utf8)!)
        XCTAssertEqual(result, expectedResult)
    }
}

