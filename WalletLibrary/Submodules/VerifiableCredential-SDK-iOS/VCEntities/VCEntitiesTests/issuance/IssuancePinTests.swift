/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCEntities

class IssuancePinTests: XCTestCase {
    
    func testNumericPinAndSalt() throws {
        let pin = "123456"
        let salt = "abcdef"
        let expectedHash = "2k7DNYoQybCHLrh3lTzHsHr19NdeTBywWXy79B5dvjU="
        let issuancePin = IssuancePin(from: pin, withSalt: salt)
        let actualHash = try issuancePin.hash()
        XCTAssertEqual(actualHash, expectedHash)
    }
    
    func testAlphanumericPinAndSalt() throws {
        let pin = "9a8b7c6d5e"
        let salt = "N0jUjyjqpj11kFCTkjFrMBY="
        let expectedHash = "cE3U/Xn4uyKbyEII+aEuTzGQIZ38JcUdFzA7sV7PtAo="
        let issuancePin = IssuancePin(from: pin, withSalt: salt)
        let actualHash = try issuancePin.hash()
        XCTAssertEqual(actualHash, expectedHash)
    }
    
    func testNumericPinAndNoSalt() throws {
        let pin = "123456"
        let expectedHash = "jZae727K08KaOmKSgOaGzww/XVqGr/PKEgIMkjrcbJI="
        let issuancePin = IssuancePin(from: pin)
        let actualHash = try issuancePin.hash()
        XCTAssertEqual(actualHash, expectedHash)
    }
    
    func testAlphanumericPinAndNoSalt() throws {
        let pin = "9a8b7c6d5e"
        let expectedHash = "9yKWBw63TMEdOc1LjHbEquXE38SFgIGtaknC784lJXg="
        let issuancePin = IssuancePin(from: pin)
        let actualHash = try issuancePin.hash()
        XCTAssertEqual(actualHash, expectedHash)
    }
}
