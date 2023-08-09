/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary
import XCTest

class DictionaryExtensionTests: XCTestCase {
    
    let jsonObject: [String: Any] = [
        "person": [
            "name": "John Doe",
            "age": 30,
            "email": "john@example.com",
            "address": [
                "city": "New York",
                "zipCode": "10001"
            ],
            "hobbies": ["reading", "traveling"]
        ]
    ]
    
    func testGetValue_WithInvalidValue_ReturnsNil() throws {
        XCTAssertNil(jsonObject.getValue(with: "person."))
        XCTAssertNil(jsonObject.getValue(with: "person..name"))
        XCTAssertNil(jsonObject.getValue(with: "person..0"))
        XCTAssertNil(jsonObject.getValue(with: "..person"))
    }
    
    func testGetValue_ForNonExistingPaths_ReturnsNil() throws {
        XCTAssertNil(jsonObject.getValue(with: "person.notfound"))
        XCTAssertNil(jsonObject.getValue(with: "person.hobbies.2"))
        XCTAssertNil(jsonObject.getValue(with: "notfound"))
    }
    
    func testGetValue_ForExistingPaths_ReturnsValue() throws {
        XCTAssertEqual(jsonObject.getValue(with: "person.name") as? String, "John Doe")
        XCTAssertEqual(jsonObject.getValue(with: "person.age") as? Int, 30)
        XCTAssertEqual(jsonObject.getValue(with: "person.address.city") as? String, "New York")
        XCTAssertEqual(jsonObject.getValue(with: "person.hobbies.0") as? String, "reading")
        XCTAssertEqual(jsonObject.getValue(with: "$.person.hobbies.0") as? String, "reading")
        XCTAssertEqual(jsonObject.getValue(with: "$person.hobbies.0") as? String, "reading")
    }
}
