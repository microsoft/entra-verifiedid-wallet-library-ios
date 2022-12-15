/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class IdTokenDescriptorMappingTests: XCTestCase {
    
    let mapper = Mapper()
    
    let encoder = JSONEncoder()
    
    let decoder = JSONDecoder()
    
    let expectedConfiguration = "https://test.com"
    let expectedClientId = "clientId12"
    let expectedRedirectUri = "redirectUri645"
    let expectedScope = "scope234"
    
    func testSuccessfulMapping() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: false)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithEncryptedAsTrueValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: true, required: false)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithEncryptedAsNilValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: nil, required: false)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithRequiredAsTrueValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: true)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithRequiredAsNilValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: nil)
        let actualResult = try mapper.map(input)
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithNoRedirectUrlPresentError() throws {
        let mockedInput = MockIdTokenDescriptor(encrypted: false,
                                                claims: [],
                                                idTokenRequired: false,
                                                configuration: expectedConfiguration,
                                                clientID: expectedClientId,
                                                redirectURI: nil,
                                                scope: expectedScope)
        
        let input = try setUpInput(mockedInput: mockedInput)
        
        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "redirectURI", in: String(describing: IdTokenDescriptor.self)))
        }
    }
    
    func testMappingWithNoClientIdPresentError() throws {
        let mockedInput = MockIdTokenDescriptor(encrypted: false,
                                                claims: [],
                                                idTokenRequired: false,
                                                configuration: "$|[%=",
                                                clientID: expectedConfiguration,
                                                redirectURI: expectedRedirectUri,
                                                scope: expectedScope)
        
        let input = try setUpInput(mockedInput: mockedInput)
        
        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .InvalidProperty(property: "configuration", in: String(describing: IdTokenDescriptor.self)))
        }
    }
    
    func testMappingWithNoScopePresentError() throws {
        let mockedInput = MockIdTokenDescriptor(encrypted: false,
                                                claims: [],
                                                idTokenRequired: false,
                                                configuration: expectedConfiguration,
                                                clientID: expectedClientId,
                                                redirectURI: expectedRedirectUri,
                                                scope: nil)
        
        let input = try setUpInput(mockedInput: mockedInput)
        
        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "scope", in: String(describing: IdTokenDescriptor.self)))
        }
    }
    
    private func setUpInput(encrypted: Bool?, required: Bool?) throws -> (IdTokenDescriptor, IdTokenRequirement) {
        let mockedInput = MockIdTokenDescriptor(encrypted: encrypted,
                                                claims: [],
                                                idTokenRequired: required,
                                                configuration: expectedConfiguration,
                                                clientID: expectedClientId,
                                                redirectURI: expectedRedirectUri,
                                                scope: expectedScope)
        
        let expectedResult = IdTokenRequirement(encrypted: encrypted ?? false,
                                                required: required ?? false,
                                                configuration: URL(string: expectedConfiguration)!,
                                                clientId: expectedClientId,
                                                redirectUri: expectedRedirectUri,
                                                scope: expectedScope)
        
        let input = try setUpInput(mockedInput: mockedInput)
        return (input, expectedResult)
    }
    
    private func setUpInput(mockedInput: MockIdTokenDescriptor) throws -> IdTokenDescriptor {
        let encodedData = try encoder.encode(mockedInput)
        let expectedInput = try decoder.decode(IdTokenDescriptor.self, from: encodedData)
        return expectedInput
    }
}
