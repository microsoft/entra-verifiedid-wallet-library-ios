/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
import VCToken

@testable import VCNetworking

class DIDDocumentDecoderTests: XCTestCase {
    
    var expectedDocument: IdentifierDocument!
    var encodedDiscoveryServiceResponse: Data!
    let decoder = DIDDocumentDecoder()
    let mockPublicKey = ECPublicJwk(x: "x", y: "y", keyId: "keyId")
    
    override func setUpWithError() throws {
        let publicKey = IdentifierDocumentPublicKey(id: "idTest",
                                                      type: "typeTest",
                                                      controller: "controllerTest",
                                                      publicKeyJwk: mockPublicKey,
                                                      purposes: [])
        expectedDocument = IdentifierDocument(service: [],
                                              verificationMethod: [publicKey],
                                              authentication: ["authTest"],
                                              id: "did:test:2343")
        encodedDiscoveryServiceResponse = try JSONEncoder().encode(DiscoveryServiceResponse(didDocument: expectedDocument))
    }
    
    func testDecode() throws {
        let actualDocument = try decoder.decode(data: encodedDiscoveryServiceResponse)
        XCTAssertEqual(actualDocument, expectedDocument)
    }
}

