/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import XCTest
@testable import VCCrypto

class HmacSha512Tests: XCTestCase {
    
    private let secret = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    private var hmac: HmacSha512!
    
    override func setUpWithError() throws {
        self.hmac = HmacSha512()
    }
    
    func testUtf() throws {
        try runAuthenticateTest(for: Utf8TestData.hello.rawValue,
                    expecting: "368f91fd6ac70cb1d00035dfa5047a3f258111c7d80650c4de9bf7da20d23ba20aee6f94d3bdf325dc70a2735cf51a910c4364c0802eb4098cdbce813d97df87")
    }
    
    func testSingleLetter() throws {
        try runAuthenticateTest(for: Utf8TestData.letter.rawValue,
                    expecting: "56792eedd50178da27ac4f09bd7f634874ed7af9e249ad7a66f686c7958b0b25a88acb02c74bfa844afb1d062b887dcd06debe0f8ff5058162734a65634bcfe7")
        
    }
    
    func testLongUtf() throws {
        try runAuthenticateTest(for: Utf8TestData.longString.rawValue,
                    expecting: "38242eff135d85c2beac9a521332af4662f043c0ecdbc0a5afb58d9550c6d24204dbc9585c20ab03904c4f21d6d2908a4119d75ef1b821f0ad30420152fb31f4")
        
    }
    
    func testValidate() throws {
        let result = try hmac.isValidAuthenticationCode(
            Data(hexString:"368f91fd6ac70cb1d00035dfa5047a3f258111c7d80650c4de9bf7da20d23ba20aee6f94d3bdf325dc70a2735cf51a910c4364c0802eb4098cdbce813d97df87"),
            authenticating: Utf8TestData.hello.rawValue.data(using: .utf8)!,
            withSecret: EphemeralSecret(with: secret.data(using: .utf8)!))
        XCTAssertTrue(result)
    }
    
    func testInvalid() throws {
        let result = try hmac.isValidAuthenticationCode(
            Data(hexString:"aaaa91fd6ac70cb1d00035dfa5047a3f258111c7d80650c4de9bf7da20d23ba20aee6f94d3bdf325dc70a2735cf51a910c4364c0802eb4098cdbce813d97df87"),
            authenticating: Utf8TestData.hello.rawValue.data(using: .utf8)!,
            withSecret: EphemeralSecret(with: secret.data(using: .utf8)!))
        XCTAssertFalse(result)
    }
    
    private func runAuthenticateTest(for message: String, expecting expected: String) throws {
        let expectedResult = Data(hexString:expected)
        
        let result = try hmac.authenticate(
            message: message.data(using: .utf8)!,
            withSecret: EphemeralSecret(with: secret.data(using: .utf8)!))
        XCTAssertEqual(result, expectedResult)
    }
}
