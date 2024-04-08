/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationExchangeIdTokenBuilderTests: XCTestCase
{
    func testBuild_WithInputDescriptors_ReturnsToken() throws
    {
        // Arrange
        let mockDefinitionId = "mock defintion id"
        let mockAudience = "mock audience"
        let mockNonce = "mock nonce"
        let mockIdentifier = "mock identifier"
        let mockKey = KeyContainer(keyReference: MockCryptoSecret(id: UUID()), keyId: "mockKeyId")
        
        let descriptor = InputDescriptorMapping(id: "mockId",
                                                format: "mockFormat",
                                                path: "mockPath",
                                                pathNested: nil)
        
        let mockSigner = MockSigner(doesSignThrow: false)
        let builder = PresentationExchangeIdTokenBuilder(signer: mockSigner)
        
        // Act
        let result = try builder.build(inputDescriptors: [descriptor],
                                       definitionId: mockDefinitionId,
                                       audience: mockAudience,
                                       nonce: mockNonce,
                                       identifier: mockIdentifier,
                                       signingKey: mockKey)
        
        // Assert
        XCTAssertEqual(result.content.audience, mockAudience)
        XCTAssertEqual(result.content.nonce, mockNonce)
        XCTAssertEqual(result.content.subject, mockIdentifier)
        XCTAssertEqual(result.content.issuer, "https://self-issued.me/v2/openid-vc")
        XCTAssertEqual(result.content.vpTokenDescription.count, 1)
        XCTAssertEqual(result.content.vpTokenDescription.first?.presentationSubmission.definitionId,
                       mockDefinitionId)
        XCTAssertEqual(result.content.vpTokenDescription.first?.presentationSubmission.inputDescriptorMap.first?.format,
                       descriptor.format)
        XCTAssertEqual(result.content.vpTokenDescription.first?.presentationSubmission.inputDescriptorMap.first?.id,
                       descriptor.id)
        XCTAssertEqual(result.content.vpTokenDescription.first?.presentationSubmission.inputDescriptorMap.first?.path,
                       descriptor.path)
    }
    
    func testBuild_WhenSignerThrows_ThrowsError() throws
    {
        // Arrange
        let mockDefinitionId = "mock defintion id"
        let mockAudience = "mock audience"
        let mockNonce = "mock nonce"
        let mockIdentifier = "mock identifier"
        let mockKey = KeyContainer(keyReference: MockCryptoSecret(id: UUID()), keyId: "mockKeyId")
        
        let descriptor = InputDescriptorMapping(id: "mockId",
                                                format: "mockFormat",
                                                path: "mockPath",
                                                pathNested: nil)
        
        let mockSigner = MockSigner(doesSignThrow: true)
        let builder = PresentationExchangeIdTokenBuilder(signer: mockSigner)
        
        // Act / Assert
        XCTAssertThrowsError(try builder.build(inputDescriptors: [descriptor],
                                               definitionId: mockDefinitionId,
                                               audience: mockAudience,
                                               nonce: mockNonce,
                                               identifier: mockIdentifier,
                                               signingKey: mockKey)) { error in
            XCTAssert(error is MockSigner.ExpectedError)
            XCTAssertEqual((error as? MockSigner.ExpectedError), .SignExpectedToThrow)
        }
    }
}
