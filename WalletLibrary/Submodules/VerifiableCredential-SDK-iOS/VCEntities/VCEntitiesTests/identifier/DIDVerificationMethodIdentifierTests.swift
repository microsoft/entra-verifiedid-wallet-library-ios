/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class DIDVerificationMethodIdentifierTests: XCTestCase {

    func testInit_WithAbsoluteKeyId_Succeeds() throws {
        let identifier = DIDVerificationMethodIdentifier(keyId: "did:ion:abc123#key-1")

        XCTAssertNotNil(identifier)
        XCTAssertEqual(identifier?.did, "did:ion:abc123")
        XCTAssertEqual(identifier?.relativeId, "#key-1")
        XCTAssertEqual(identifier?.absoluteId, "did:ion:abc123#key-1")
    }

    func testInit_WithMultipleHashes_KeepsRemainderInRelativeId() throws {
        // The relative id itself must not contain a `#`, so a keyId with two `#` characters is
        // rejected rather than silently truncated.
        let identifier = DIDVerificationMethodIdentifier(keyId: "did:ion:abc123#key-1#extra")

        XCTAssertNil(identifier)
    }

    func testInit_WithoutHash_ReturnsNil() throws {
        let identifier = DIDVerificationMethodIdentifier(keyId: "did:ion:abc123")

        XCTAssertNil(identifier)
    }

    func testInit_WithEmptyDID_ReturnsNil() throws {
        let identifier = DIDVerificationMethodIdentifier(keyId: "#key-1")

        XCTAssertNil(identifier)
    }

    func testInit_WithEmptyRelativeId_ReturnsNil() throws {
        let identifier = DIDVerificationMethodIdentifier(keyId: "did:ion:abc123#")

        XCTAssertNil(identifier)
    }

    func testInit_WithEmptyKeyId_ReturnsNil() throws {
        let identifier = DIDVerificationMethodIdentifier(keyId: "")

        XCTAssertNil(identifier)
    }
}
