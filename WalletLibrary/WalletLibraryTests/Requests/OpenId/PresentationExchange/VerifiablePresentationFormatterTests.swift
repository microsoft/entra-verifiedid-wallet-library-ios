/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiablePresentationFormatterTests: XCTestCase
{
    func testFormat_WithSignerThrowing_ThrowsError() throws
    {
        // Arrange
        let mockSigner = MockSigner(doesSignThrow: true)
        let formatter = VerifiablePresentationFormatter(signer: mockSigner)
        let mockAudience = "mock audience"
        let mockNonce = "mock nonce"
        let mockIdentifier = "mock identifier"
        let mockSigningKey = KeyContainer(keyReference: MockCryptoSecret(id: UUID()), keyId: "mockKeyId")
        
        // Act / Assert
        XCTAssertThrowsError(try formatter.format(toWrap: [],
                                                  audience: mockAudience,
                                                  nonce: mockNonce,
                                                  identifier: mockIdentifier,
                                                  signingKey: mockSigningKey)) { error in
            XCTAssert(error is MockSigner.ExpectedError)
            XCTAssertEqual((error as? MockSigner.ExpectedError), .SignExpectedToThrow)
        }
    }
    
    func testFormat_WithValidInput_ReturnsVPToken() throws
    {
        // Arrange
        let mockSigner = MockSigner(doesSignThrow: false)
        let formatter = VerifiablePresentationFormatter(signer: mockSigner)
        let mockAudience = "mock audience"
        let mockNonce = "mock nonce"
        let mockIdentifier = "mock identifier"
        let mockSigningKey = KeyContainer(keyReference: MockCryptoSecret(id: UUID()), keyId: "mockKeyId")
        let mockVCs = ["mockVC1", "mockVC2"]
        
        // Act
        let token = try formatter.format(rawVCs: mockVCs,
                                         audience: mockAudience,
                                         nonce: mockNonce,
                                         identifier: mockIdentifier,
                                         signingKey: mockSigningKey)
        
        print(token)
        XCTAssertEqual(token.content.audience, mockAudience)
        XCTAssertEqual(token.content.nonce, mockNonce)
        XCTAssertEqual(token.content.issuerOfVp, mockIdentifier)
        XCTAssertEqual(token.content.verifiablePresentation.context, ["https://www.w3.org/2018/credentials/v1"])
        XCTAssertEqual(token.content.verifiablePresentation.type, ["VerifiablePresentation"])
        XCTAssertEqual(token.content.verifiablePresentation.verifiableCredential, mockVCs)
    }
}
