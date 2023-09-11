/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationResponseEncoderTests: XCTestCase {
    
    let encoder = PresentationResponseEncoder()
    
    func testEncode_WithNoVpTokens_ThrowsError() throws {
        // Arrange
        let response = PresentationResponse(idToken: mockIdToken(),
                                            vpTokens: [],
                                            state: nil)
        
        // Act
        XCTAssertThrowsError(try encoder.encode(value: response)) { error in
            // Assert
            XCTAssert(error is PresentationResponseEncoderError)
            XCTAssertEqual(error as? PresentationResponseEncoderError,
                           .noVerifiablePresentationInResponse)
        }
    }
    
    func testEncode_WithOneVpToken_EncodesValue() throws {
        // Arrange
        let idToken = mockIdToken()
        let claims = VerifiablePresentationClaims(verifiablePresentation: nil)
        let vp = VerifiablePresentation(headers: Header(),
                                        content: claims)!
        let response = PresentationResponse(idToken: idToken,
                                            vpTokens: [vp],
                                            state: nil)
        
        // Act
        let result = try encoder.encode(value: response)
        
        // Assert
        let stringifiedResult = String(data: result, encoding: .utf8)!
        XCTAssertEqual(stringifiedResult, "id_token=\(try idToken.serialize())&vp_token=\(try vp.serialize())")
    }
    
    func testEncode_WithThreeVpTokens_EncodesValue() throws {
        // Arrange
        let idToken = mockIdToken()
        let claims1 = VerifiablePresentationClaims(vpId: "vp1", verifiablePresentation: nil)
        let vp1 = VerifiablePresentation(headers: Header(),
                                        content: claims1)!
        
        let claims2 = VerifiablePresentationClaims(vpId: "vp2", verifiablePresentation: nil)
        let vp2 = VerifiablePresentation(headers: Header(),
                                        content: claims2)!
        
        let claims3 = VerifiablePresentationClaims(vpId: "vp3", verifiablePresentation: nil)
        let vp3 = VerifiablePresentation(headers: Header(),
                                        content: claims3)!
        let response = PresentationResponse(idToken: idToken,
                                            vpTokens: [vp1, vp2, vp3],
                                            state: nil)
        
        // Act
        let result = try encoder.encode(value: response)
        
        // Assert
        let stringifiedResult = String(data: result, encoding: .utf8)!
//        XCTAssertEqual(stringifiedResult, "id_token=\(try idToken.serialize())&vp_token=\(try vp1.serialize())")
    }
    
    private func mockIdToken() -> PresentationResponseToken {
        let claims = PresentationResponseClaims()
        let mockIdToken = PresentationResponseToken(headers: Header(),
                                                    content: claims)
        return mockIdToken!
    }
}
