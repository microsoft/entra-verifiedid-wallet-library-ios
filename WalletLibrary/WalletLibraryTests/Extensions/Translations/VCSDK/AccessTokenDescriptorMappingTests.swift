/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class AccessTokenDescriptorMappingTests: XCTestCase {
    
    let mapper = Mapper()
    
    let encoder = JSONEncoder()
    
    let decoder = JSONDecoder()
    
    let expectedId = "id432"
    let expectedConfiguration = "https://test.com"
    let expectedClientId = "clientId12"
    let expectedResourceId = "redirectUri645"
    let expectedScope = "scope234"
    
    func testSuccessfulMapping() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: false)
        let actualResult = try mapper.map(input)
        assertEquals(actual: actualResult, expected: expectedResult)
    }
    
    func testMappingWithEncryptedAsTrueValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: true, required: false)
        let actualResult = try mapper.map(input)
        assertEquals(actual: actualResult, expected: expectedResult)
    }
    
    func testMappingWithEncryptedAsNilValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: nil, required: false)
        let actualResult = try mapper.map(input)
        assertEquals(actual: actualResult, expected: expectedResult)
    }
    
    func testMappingWithRequiredAsTrueValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: true)
        let actualResult = try mapper.map(input)
        assertEquals(actual: actualResult, expected: expectedResult)
    }
    
    func testMappingWithRequiredAsNilValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: nil)
        let actualResult = try mapper.map(input)
        assertEquals(actual: actualResult, expected: expectedResult)
    }
    
    func testMappingWithNoConfigurationPresentError() throws {
        let input = AccessTokenDescriptor(id: expectedId,
                                          encrypted: false,
                                          claims: [],
                                          required: false,
                                          configuration: nil,
                                          resourceId: expectedResourceId,
                                          oboScope: expectedScope)
        
        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "configuration",
                                               in: String(describing: AccessTokenDescriptor.self)))
        }
    }
    
    func testMappingWithNoResourceIdPresentError() throws {
        let input = AccessTokenDescriptor(id: expectedId,
                                          encrypted: false,
                                          claims: [],
                                          required: false,
                                          configuration: expectedConfiguration,
                                          resourceId: nil,
                                          oboScope: expectedScope)
        
        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "resourceId",
                                               in: String(describing: AccessTokenDescriptor.self)))
        }
    }
    
    func testMappingWithNoScopePresentError() throws {
        let input = AccessTokenDescriptor(id: expectedId,
                                          encrypted: false,
                                          claims: [],
                                          required: false,
                                          configuration: expectedConfiguration,
                                          resourceId: expectedResourceId,
                                          oboScope: nil)
        
        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "oboScope",
                                               in: String(describing: AccessTokenDescriptor.self)))
        }
    }
    
    private func assertEquals(actual: AccessTokenRequirement, expected: AccessTokenRequirement) {
        XCTAssertEqual(actual.encrypted, expected.encrypted)
        XCTAssertEqual(actual.required, expected.required)
        XCTAssertEqual(actual.configuration, expected.configuration)
        XCTAssertEqual(actual.clientId, expected.clientId)
        XCTAssertEqual(actual.resourceId, expected.resourceId)
        XCTAssertEqual(actual.scope, expected.scope)
    }
    
    private func setUpInput(encrypted: Bool?,
                            required: Bool?) throws -> (AccessTokenDescriptor, AccessTokenRequirement) {
        let input = AccessTokenDescriptor(id: expectedId,
                                          encrypted: encrypted,
                                          claims: [],
                                          required: required,
                                          configuration: expectedConfiguration,
                                          resourceId: expectedResourceId,
                                          oboScope: expectedScope)
        
        let expectedResult = AccessTokenRequirement(encrypted: encrypted ?? false,
                                                    required: required ?? false,
                                                    configuration: expectedConfiguration,
                                                    clientId: nil,
                                                    resourceId: expectedResourceId,
                                                    scope: expectedScope)
        
        return (input, expectedResult)
    }
}
