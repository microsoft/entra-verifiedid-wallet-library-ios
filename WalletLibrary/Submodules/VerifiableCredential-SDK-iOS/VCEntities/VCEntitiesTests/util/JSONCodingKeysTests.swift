/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCEntities

class JSONCodingKeysTests: XCTestCase {
    
    func testCodingKeysExtension() throws {
        let dictionary = ["key1": 1, "key2": "test235", "key3": true, "key4": 6.6, "key5": [:] as [String: Any]] as [String : Any]
        let expectedObj = MockCodableObject(test: dictionary)
        let serializedObj = try JSONEncoder().encode(expectedObj)
        let actualObj = try JSONDecoder().decode(MockCodableObject.self, from: serializedObj)
        XCTAssertEqual(expectedObj.test["key1"] as! Int, actualObj.test["key1"] as! Int)
        XCTAssertEqual(expectedObj.test["key2"] as! String, actualObj.test["key2"] as! String)
        XCTAssertEqual(expectedObj.test["key3"] as! Bool, actualObj.test["key3"] as! Bool)
        XCTAssertEqual(expectedObj.test["key4"] as! Double, actualObj.test["key4"] as! Double)
        XCTAssertNotNil(expectedObj.test["key5"] as? [String: Any])
    }
}
