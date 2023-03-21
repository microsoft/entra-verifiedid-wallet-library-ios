/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdEncoderTests: XCTestCase {
    
    func testEncode_WithVerifiedIdThatIsUnableToBeEncoded_ThrowsError() async throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mockVerifiedId", double: Double.infinity, issuedOn: Date())
        let encoder = VerifiedIdEncoder()

        // Act
        XCTAssertThrowsError(try encoder.encode(verifiedId: mockVerifiedId)) { error in
            // Assert
            XCTAssert(error is VerifiedIdEncoderError)
            XCTAssertEqual(error as? VerifiedIdEncoderError, .unableToEncodeVerifiedId)
        }
    }
    
    func testDecode_WithValidVerifiedId_ReturnsData() async throws {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mockVerifiedId", issuedOn: Date())
        let encodedMockVerifiedId = try JSONEncoder().encode(mockVerifiedId)
        let encoder = VerifiedIdEncoder()
        
        // Act
        let actualResult = try encoder.encode(verifiedId: mockVerifiedId)
        
        // Assert
        let encodedVerifiedId = try JSONDecoder().decode(EncodedVerifiedId.self, from: actualResult)
        XCTAssertEqual(encodedVerifiedId.raw, encodedMockVerifiedId)
        XCTAssertEqual(encodedVerifiedId.type, "MockVerifiedId")
    }
}
