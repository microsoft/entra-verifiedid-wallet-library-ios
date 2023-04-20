/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
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
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithEncryptedAsTrueValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: true, required: false)
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithEncryptedAsNilValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: nil, required: false)
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithRequiredAsTrueValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: true)
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithRequiredAsNilValue() throws {
        let (input, expectedResult) = try setUpInput(encrypted: false, required: nil)
        let actualResult = try mapper.map(input)
        assertEqual(actualResult, expectedResult)
    }
    
    func testMappingWithNoRedirectUrlPresentError() throws {
        let input = IdTokenDescriptor(encrypted: false,
                                      claims: [],
                                      idTokenRequired: false,
                                      configuration: expectedConfiguration,
                                      clientID: expectedClientId,
                                      redirectURI: nil,
                                      scope: expectedScope)
        
        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "redirectURI", in: String(describing: IdTokenDescriptor.self)))
        }
    }
    
    func testMappingWithNoClientIdPresentError() throws {
        let input = IdTokenDescriptor(encrypted: false,
                                      claims: [],
                                      idTokenRequired: false,
                                      configuration: "$|[%=",
                                      clientID: expectedConfiguration,
                                      redirectURI: expectedRedirectUri,
                                      scope: expectedScope)
        
        XCTAssertThrowsError(try mapper.map(input)) { error in
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .InvalidProperty(property: "configuration", in: String(describing: IdTokenDescriptor.self)))
        }
    }
    
    private func assertEqual(_ actual: IdTokenRequirement, _ expected: IdTokenRequirement) {
        XCTAssertEqual(actual.encrypted, expected.encrypted)
        XCTAssertEqual(actual.required, expected.required)
        XCTAssertEqual(actual.configuration, expected.configuration)
        XCTAssertEqual(actual.clientId, expected.clientId)
        XCTAssertEqual(actual.redirectUri, expected.redirectUri)
        XCTAssertEqual(actual.scope, expected.scope)
        XCTAssertEqual(actual.nonce, expected.nonce)
    }
    
    private func setUpInput(encrypted: Bool?, required: Bool?) throws -> (IdTokenDescriptor, IdTokenRequirement) {
        let input = IdTokenDescriptor(encrypted: encrypted,
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
        
        return (input, expectedResult)
    }
}
