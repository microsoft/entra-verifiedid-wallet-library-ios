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
    
    func testSuccessfulTranslation() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: false)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testTranslationWithEncryptedAsTrueValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: true, required: false)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testTranslationWithEncryptedAsNilValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: nil, required: false)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testTranslationWithRequiredAsTrueValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: true)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testTranslationWithRequiredAsNilValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: nil)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testTranslationWithNoConfigurationPresentError() throws {
        let mockedInput = MockAccessTokenDescriptor(id: expectedId,
                                                    encrypted: false,
                                                    claims: [],
                                                    required: false,
                                                    configuration: nil,
                                                    resourceId: expectedResourceId,
                                                    oboScope: expectedScope)
        
        let input = try setUpInput(mockedInput: mockedInput)
        
        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "configuration",
                                               in: String(describing: AccessTokenDescriptor.self)))
        }
    }
    
    func testTranslationWithNoResourceIdPresentError() throws {
        let mockedInput = MockAccessTokenDescriptor(id: expectedId,
                                                    encrypted: false,
                                                    claims: [],
                                                    required: false,
                                                    configuration: expectedConfiguration,
                                                    resourceId: nil,
                                                    oboScope: expectedScope)
        
        let input = try setUpInput(mockedInput: mockedInput)
        
        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "resourceId",
                                               in: String(describing: AccessTokenDescriptor.self)))
        }
    }
    
    func testTranslationWithNoScopePresentError() throws {
        let mockedInput = MockAccessTokenDescriptor(id: expectedId,
                                                    encrypted: false,
                                                    claims: [],
                                                    required: false,
                                                    configuration: expectedConfiguration,
                                                    resourceId: expectedResourceId,
                                                    oboScope: nil)
        
        let input = try setUpInput(mockedInput: mockedInput)
        
        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "oboScope",
                                               in: String(describing: AccessTokenDescriptor.self)))
        }
    }
    
    private func setUpInput(encrypted: Bool?,
                            required: Bool?) throws -> (AccessTokenDescriptor, AccessTokenRequirement) {
        let mockedInput = MockAccessTokenDescriptor(id: expectedId,
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
        
        let input = try setUpInput(mockedInput: mockedInput)
        return (input, expectedResult)
    }
    
    private func setUpInput(mockedInput: MockAccessTokenDescriptor) throws -> AccessTokenDescriptor {
        let encodedData = try encoder.encode(mockedInput)
        let expectedInput = try decoder.decode(AccessTokenDescriptor.self, from: encodedData)
        return expectedInput
    }
    
    
}

