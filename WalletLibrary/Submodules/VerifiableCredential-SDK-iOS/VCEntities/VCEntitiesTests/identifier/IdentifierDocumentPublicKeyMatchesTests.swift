/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class IdentifierDocumentPublicKeyMatchesTests: XCTestCase {

    private let mockPublicKey = PublicJWK(x: "x",
                                           y: "y",
                                           keyType: "EC",
                                           keyId: "keyId",
                                           algorithm: "mockAlgorithm",
                                           curve: "mockCurve")

    func testMatches_WithAbsoluteIdAndMatchingController_ReturnsTrue() throws {
        let key = createPublicKey(id: "did:ion:abc123#key-1", controller: "did:ion:abc123")
        let keyIdentifier = try XCTUnwrap(DIDVerificationMethodIdentifier(keyId: "did:ion:abc123#key-1"))

        XCTAssertTrue(key.matches(keyIdentifier))
    }

    func testMatches_WithRelativeIdAndMatchingController_ReturnsTrue() throws {
        let key = createPublicKey(id: "#key-1", controller: "did:ion:abc123")
        let keyIdentifier = try XCTUnwrap(DIDVerificationMethodIdentifier(keyId: "did:ion:abc123#key-1"))

        XCTAssertTrue(key.matches(keyIdentifier))
    }

    func testMatches_WithRelativeIdAndNilController_ReturnsTrue() throws {
        // A missing `controller` implicitly means the DID document's own subject, so it must
        // still match the requested DID.
        let key = createPublicKey(id: "#key-1", controller: nil)
        let keyIdentifier = try XCTUnwrap(DIDVerificationMethodIdentifier(keyId: "did:ion:abc123#key-1"))

        XCTAssertTrue(key.matches(keyIdentifier))
    }

    func testMatches_WithMismatchedController_ReturnsFalse() throws {
        let key = createPublicKey(id: "did:ion:abc123#key-1", controller: "did:ion:someoneElse")
        let keyIdentifier = try XCTUnwrap(DIDVerificationMethodIdentifier(keyId: "did:ion:abc123#key-1"))

        XCTAssertFalse(key.matches(keyIdentifier))
    }

    func testMatches_WithMismatchedId_ReturnsFalse() throws {
        let key = createPublicKey(id: "#key-2", controller: "did:ion:abc123")
        let keyIdentifier = try XCTUnwrap(DIDVerificationMethodIdentifier(keyId: "did:ion:abc123#key-1"))

        XCTAssertFalse(key.matches(keyIdentifier))
    }

    func testMatches_WithAbsoluteIdBelongingToDifferentDID_ReturnsFalse() throws {
        // Even though the fragment matches, an absolute `id` scoped to a different DID must not
        // be treated as belonging to the requested DID.
        let key = createPublicKey(id: "did:ion:someoneElse#key-1", controller: nil)
        let keyIdentifier = try XCTUnwrap(DIDVerificationMethodIdentifier(keyId: "did:ion:abc123#key-1"))

        XCTAssertFalse(key.matches(keyIdentifier))
    }

    private func createPublicKey(id: String, controller: String?) -> IdentifierDocumentPublicKey {
        IdentifierDocumentPublicKey(id: id,
                                     type: "Typetest",
                                     controller: controller,
                                     publicKeyJwk: mockPublicKey,
                                     purposes: ["purpose"])
    }
}
