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
    
    func testToURLEncodedString_WithEmptyDict_ReturnsEmptyString() throws
    {
        // Arrange
        let emptyDictionary: Dictionary<String, String?> = [:]
        
        // Act / Assert
        XCTAssertEqual(emptyDictionary.toURLEncodedString(), "")
        
    }
    
    func testToURLEncodedString_WithOneValue_ReturnsString() throws
    {
        // Arrange
        let emptyDictionary: Dictionary<String, String?> = ["key": "value"]
        
        // Act / Assert
        XCTAssertEqual(emptyDictionary.toURLEncodedString(), "key=value")
        
    }
    
    func testToURLEncodedString_WithThreeValues_ReturnsString() throws
    {
        // Arrange
        let emptyDictionary: Dictionary<String, String?> = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3"
        ]
        
        // Act
        let result = emptyDictionary.toURLEncodedString()
        
        // Assert
        let parts = result.split(separator: "&")
        XCTAssertEqual(parts.count, 3)
        XCTAssert(parts.contains { $0 == "key1=value1"})
        XCTAssert(parts.contains { $0 == "key2=value2"})
        XCTAssert(parts.contains { $0 == "key3=value3"})
    }
    
    func testToURLEncodedString_WithOneNilValue_ReturnsString() throws
    {
        // Arrange
        let emptyDictionary: Dictionary<String, String?> = [
            "key1": "value1",
            "key2": nil,
            "key3": "value3"
        ]
        
        // Act
        let result = emptyDictionary.toURLEncodedString()
        
        // Assert
        let parts = result.split(separator: "&")
        XCTAssertEqual(parts.count, 2)
        XCTAssert(parts.contains { $0 == "key1=value1"})
        XCTAssertFalse(parts.contains { $0.contains("key2") })
        XCTAssert(parts.contains { $0 == "key3=value3"})
    }
}
