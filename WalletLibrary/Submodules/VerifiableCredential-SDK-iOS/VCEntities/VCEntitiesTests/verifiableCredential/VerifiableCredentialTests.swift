/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest

@testable import VCEntities

class VerifiableCredentialTests: XCTestCase {
    
    func testEncodingVcDescriptor() throws {
        let context = ["context"]
        let type = ["type"]
        let credentialSubject = ["key1": 42, "key2": "test2353"] as [String : Any]
        let expectedVcDescriptor = VerifiableCredentialDescriptor(context: context,
                                                                  type: type,
                                                                  credentialSubject: credentialSubject,
                                                                  exchangeService: nil)
        let serializedDescriptor = try JSONEncoder().encode(expectedVcDescriptor)
        let actualVcDescriptor = try JSONDecoder().decode(VerifiableCredentialDescriptor.self, from: serializedDescriptor)
        XCTAssertEqual(actualVcDescriptor.context, context)
        XCTAssertEqual(actualVcDescriptor.type, type)
        XCTAssertEqual(actualVcDescriptor.credentialSubject?["key1"] as! Int, credentialSubject["key1"] as! Int)
        XCTAssertEqual(actualVcDescriptor.credentialSubject?["key2"] as! String, credentialSubject["key2"] as! String)
    }
}
