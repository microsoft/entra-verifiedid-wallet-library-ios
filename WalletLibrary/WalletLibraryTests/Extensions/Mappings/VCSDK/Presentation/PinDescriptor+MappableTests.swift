/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class PinDescriptorMappingTests: XCTestCase {
    
    func testMap_WithNilType_ThrowsError() throws {
        // Arrange
        let mockMapper = MockMapper()
        let pinDescriptor = PinDescriptor(type: nil,
                                          length: 4,
                                          hash: "hash",
                                          salt: nil,
                                          iterations: nil,
                                          alg: nil)
        
        // Act
        XCTAssertThrowsError(try mockMapper.map(pinDescriptor)) { error in
            // Assert
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError, .PropertyNotPresent(property: "type", in: "PinDescriptor"))
        }
    }
    
    func testMap_WithNilSalt_ReturnsPinRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let pinDescriptor = PinDescriptor(type: "mock type",
                                          length: 4,
                                          hash: "hash",
                                          salt: nil,
                                          iterations: nil,
                                          alg: nil)
        
        // Act
        let actualResult = try mockMapper.map(pinDescriptor)
        
        // Assert
        XCTAssert(actualResult.required)
        XCTAssertEqual(actualResult.type, "mock type")
        XCTAssertEqual(actualResult.length, 4)
        XCTAssertEqual(actualResult.salt, nil)
        XCTAssertEqual(actualResult.pin, nil)
    }
    
    func testMap_WithSalt_ReturnsPinRequirement() throws {
        // Arrange
        let mockMapper = MockMapper()
        let pinDescriptor = PinDescriptor(type: "mock type",
                                          length: 8,
                                          hash: "hash",
                                          salt: "mock salt",
                                          iterations: nil,
                                          alg: nil)
        
        // Act
        let actualResult = try mockMapper.map(pinDescriptor)
        
        // Assert
        XCTAssert(actualResult.required)
        XCTAssertEqual(actualResult.type, "mock type")
        XCTAssertEqual(actualResult.length, 8)
        XCTAssertEqual(actualResult.salt, "mock salt")
        XCTAssertEqual(actualResult.pin, nil)
    }
}
