/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCCrypto
import VCToken

@testable import VCEntities

class IdentifierCreatorTests: XCTestCase {
    
    var keyManagementOperations: KeyManagementOperating!
    let expectedResult = "result2353"
    
    override func setUpWithError() throws {
        self.keyManagementOperations = MockKeyManagementOperations(secretStore: SecretStoreMock())
        
        MockKeyManagementOperations.generateKeyCallCount = 0
    }

    func testCreateIdentifier() throws {
        let creator = IdentifierCreator(keyManagementOperations: keyManagementOperations, identifierFormatter: MockIdentifierFormatter(returningString: self.expectedResult))
        let actualResult = try creator.create(forId: "test3", andRelyingParty: "test43")
        XCTAssertEqual(MockKeyManagementOperations.generateKeyCallCount, 3)
        XCTAssertEqual(actualResult.longFormDid, expectedResult)
    }
    
    func testCreateIdentifierWithCryptoOperations() throws {
        let creator = IdentifierCreator(keyManagementOperations: keyManagementOperations)
        let _ = try creator.create(forId: "test233", andRelyingParty: "test2343")
        XCTAssertEqual(MockKeyManagementOperations.generateKeyCallCount, 3)
    }
}
