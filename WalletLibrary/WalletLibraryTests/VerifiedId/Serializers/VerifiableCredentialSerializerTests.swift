/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiableCredentialSerializerTests: XCTestCase
{
    func testSerialize_WithInvalidType_ThrowsError() async throws
    {
        // Arrange
        let mockVerifiedId = MockVerifiedId(id: "mockId", issuedOn: Date())
        let serializer = VerifiableCredentialSerializer()
        
        // Act / Assert
        XCTAssertThrowsError(try serializer.serialize(verifiedId: mockVerifiedId)) { error in
            XCTAssert(error is MalformedInputError)
            XCTAssertEqual((error as? MalformedInputError)?.code, "malformed_input_error")
            XCTAssertEqual((error as? MalformedInputError)?.message, "Unsupported Verified ID Type during serialization: MockVerifiedId.")
        }
    }
    
    func testSerialize_WithValidType_ReturnsSerializedVC() async throws
    {
        // Arrange
        let mockVerifiedId = MockVerifiableCredentialHelper().createMockVerifiableCredential()
        let serializer = VerifiableCredentialSerializer()
        
        // Act
        let result = try serializer.serialize(verifiedId: mockVerifiedId)
        
        // Assert
        XCTAssertEqual(result, try mockVerifiedId.raw.serialize())
    }
}
