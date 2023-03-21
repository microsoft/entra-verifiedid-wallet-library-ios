/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdDecoderTests: XCTestCase {
    
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
        let mockEncodedVerifiedId = EncodedVerifiedId(type: "VerifiableCredential",
                                                      raw: "mock raw data".data(using: .utf8)!)
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
        let mockEncodedVerifiedId = EncodedVerifiedId(type: "unsupportedVerifiedIdType",
                                                      raw: "mock raw data".data(using: .utf8)!)
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
        let mockEncodedVerifiedId = EncodedVerifiedId(type: "VerifiableCredential",
                                                      raw: encodedVerifiableCredential)
        let mockEncodedVerifiedIdData = try JSONEncoder().encode(mockEncodedVerifiedId)
        let decoder = VerifiedIdDecoder()
        
        // Act
        let actualResult: VerifiableCredential = try decoder.decode(from: mockEncodedVerifiedIdData) as! VerifiableCredential
        
        // Assert
        XCTAssertEqual(try actualResult.raw.serialize(), try mockVC.raw.serialize())
        XCTAssertEqual(actualResult.contract, mockVC.contract)
        XCTAssertEqual(actualResult.expiresOn, mockVC.expiresOn)
        XCTAssertEqual(actualResult.issuedOn, mockVC.issuedOn)
        XCTAssertEqual(actualResult.id, mockVC.id)
    }
}
