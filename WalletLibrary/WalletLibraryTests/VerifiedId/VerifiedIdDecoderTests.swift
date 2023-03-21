/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdDecoderTests: XCTestCase {
    
    struct MockEncodedVerifiedId: Codable {
        let raw: Data
        
        let type: String
    }
    
    func testDecode_WithInvalidRawInputData_ThrowsError() async throws {
        // Arrange
        let decoder = VerifiedIdDecoder()

        // Act
        XCTAssertThrowsError(try decoder.decode(from: "mock raw data".data(using: .utf8)!)) { error in
            // Assert
            XCTAssert(error is VerifiedIdDecoderError)
            XCTAssertEqual(error as? VerifiedIdDecoderError, .unableToDecodeVerifiedId)
        }
    }
    
    func testDecode_WithInvalidRawVerifiedIdData_ThrowsError() async throws {
        // Arrange
        let mockEncodedVerifiedId = MockEncodedVerifiedId(raw: "mock raw data".data(using: .utf8)!,
                                                          type: SupportedVerifiedIdType.VerifiableCredential.rawValue)
        let mockEncodedVerifiedIdData = try JSONEncoder().encode(mockEncodedVerifiedId)
        let decoder = VerifiedIdDecoder()

        // Act
        XCTAssertThrowsError(try decoder.decode(from: mockEncodedVerifiedIdData)) { error in
            // Assert
            XCTAssert(error is VerifiedIdDecoderError)
            XCTAssertEqual(error as? VerifiedIdDecoderError, .unableToDecodeVerifiedId)
        }
    }
    
    func testDecode_WithUnsupportedVerifedIdType_ThrowsError() async throws {
        // Arrange
        let mockEncodedVerifiedId = MockEncodedVerifiedId(raw: "mock raw data".data(using: .utf8)!,
                                                          type: "unsupportedVerifiedIdType")
        let mockEncodedVerifiedIdData = try JSONEncoder().encode(mockEncodedVerifiedId)
        let decoder = VerifiedIdDecoder()

        // Act
        XCTAssertThrowsError(try decoder.decode(from: mockEncodedVerifiedIdData)) { error in
            // Assert
            XCTAssert(error is VerifiedIdDecoderError)
            XCTAssertEqual(error as? VerifiedIdDecoderError, .unsupportedVerifiedIdType)
        }
    }
    
    func testDecode_WithValidRawVerifiedIdData_ReturnsVerifiedId() async throws {
        // Arrange
        let mockVC = MockVerifiableCredentialHelper().createMockVerifiableCredential()
        let encodedVerifiableCredential = try JSONEncoder().encode(mockVC)
        let mockEncodedVerifiedId = MockEncodedVerifiedId(raw: encodedVerifiableCredential,
                                                          type: SupportedVerifiedIdType.VerifiableCredential.rawValue)
        let mockEncodedVerifiedIdData = try JSONEncoder().encode(mockEncodedVerifiedId)
        let decoder = VerifiedIdDecoder()
        
        // Act
        let actualResult: VerifiableCredential = try decoder.decode(from: mockEncodedVerifiedIdData) as! VerifiableCredential
        
        XCTAssertEqual(try actualResult.raw.serialize(), try mockVC.raw.serialize())
        XCTAssertEqual(actualResult.contract, mockVC.contract)
        XCTAssertEqual(actualResult.expiresOn, mockVC.expiresOn)
        XCTAssertEqual(actualResult.issuedOn, mockVC.issuedOn)
        XCTAssertEqual(actualResult.id, mockVC.id)
    }
}
