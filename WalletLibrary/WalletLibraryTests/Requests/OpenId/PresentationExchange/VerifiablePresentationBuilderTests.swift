/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiablePresentationBuilderTests: XCTestCase
{
    func testCanInclude_WithOneNonCompatPartialInputDescriptor_ReturnsFalse() throws
    {
        // Arrange
        let requirement = MockPresentationExchangeRequirement(inputDescriptorId: "1",
                                                              exclusivePresentationWith: ["2"])
        let descriptor = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement)
        
        let inputReq = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        let input = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: inputReq)
        
        let index = 1
        
        let builder = VerifiablePresentationBuilder(index: index)
        builder.add(partialInputDescriptor: descriptor)
        
        // Act / Assert
        XCTAssertFalse(builder.canInclude(partialInputDescriptor: input))
    }
    
    func testCanInclude_WithAllCompatPartialInputDescriptor_ReturnsTrue() throws
    {
        // Arrange
        let requirement1 = MockPresentationExchangeRequirement(inputDescriptorId: "1")
        let descriptor1 = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement1)
        
        let requirement2 = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        let descriptor2 = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement2)
        
        let inputReq = MockPresentationExchangeRequirement(inputDescriptorId: "3")
        let input = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: inputReq)
        
        let index = 1
        
        let builder = VerifiablePresentationBuilder(index: index)
        builder.add(partialInputDescriptor: descriptor1)
        builder.add(partialInputDescriptor: descriptor2)
        
        // Act / Assert
        XCTAssert(builder.canInclude(partialInputDescriptor: input))
    }
    
    func testBuildInputDescriptors_WithOnePartial_ReturnsInputDescriptors() throws
    {
        // Arrange
        let inputReq = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        let input = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: inputReq)
        
        let index = 1
        
        let builder = VerifiablePresentationBuilder(index: index)
        builder.add(partialInputDescriptor: input)
        
        // Act
        let result = builder.buildInputDescriptors()
        
        // Assert
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.format, "jwt_vp")
        XCTAssertEqual(result.first?.id, inputReq.inputDescriptorId)
        XCTAssertEqual(result.first?.path, "$[1]")
        XCTAssertEqual(result.first?.pathNested?.format, "jwt_vc")
        XCTAssertEqual(result.first?.pathNested?.id, inputReq.inputDescriptorId)
        XCTAssertEqual(result.first?.pathNested?.path, "$[1].verifiableCredential[0]")
    }
    
    func testBuildInputDescriptors_WithThreePartials_ReturnsInputDescriptors() throws
    {
        // Arrange
        let requirement1 = MockPresentationExchangeRequirement(inputDescriptorId: "0")
        let descriptor1 = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement1)
        
        let requirement2 = MockPresentationExchangeRequirement(inputDescriptorId: "1")
        let descriptor2 = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement2)
        
        let requirement3 = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        let descriptor3 = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement3)
        
        let index = 1
        
        let builder = VerifiablePresentationBuilder(index: index)
        builder.add(partialInputDescriptor: descriptor1)
        builder.add(partialInputDescriptor: descriptor2)
        builder.add(partialInputDescriptor: descriptor3)
        
        // Act
        let results = builder.buildInputDescriptors()
        
        // Assert
        XCTAssertEqual(results.count, 3)
        for (index, result) in results.enumerated()
        {
            XCTAssertEqual(result.format, "jwt_vp")
            XCTAssertEqual(result.id, String(index))
            XCTAssertEqual(result.path, "$[1]")
            XCTAssertEqual(result.pathNested?.format, "jwt_vc")
            XCTAssertEqual(result.pathNested?.id, String(index))
            XCTAssertEqual(result.pathNested?.path, "$[1].verifiableCredential[\(index)]")
        }
    }
    
    func testBuildVerifiablePresentation_WithOnePartial_ReturnsVP() throws
    {
        // Arrange
        let mockAudience = "mock audience"
        let mockNonce = "mock nonce"
        let mockIdentifier = "mock identifier"
        let mockKey = KeyContainer(keyReference: MockCryptoSecret(id: UUID()), keyId: "mockKeyId")
        let inputReq = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        let input = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: inputReq)
        
        let index = 1
        
        let formatter = VerifiablePresentationFormatter(signer: MockSigner(doesSignThrow: false))
        let builder = VerifiablePresentationBuilder(index: index, formatter: formatter)
        builder.add(partialInputDescriptor: input)
        
        // Act
        let result = try builder.buildVerifiablePresentation(audience: mockAudience,
                                                             nonce: mockNonce,
                                                             identifier: mockIdentifier,
                                                             signingKey: mockKey)
        
        // Assert
        XCTAssertEqual(result.content.audience, mockAudience)
        XCTAssertEqual(result.content.issuerOfVp, mockIdentifier)
        XCTAssertEqual(result.content.nonce, mockNonce)
        XCTAssertEqual(result.content.verifiablePresentation.verifiableCredential, [input.serializedVerifiedId])
    }
    
    func testBuildVerifiablePresentation_WithThreePartials_ReturnsVP() throws
    {
        // Arrange
        let mockAudience = "mock audience"
        let mockNonce = "mock nonce"
        let mockIdentifier = "mock identifier"
        let mockKey = KeyContainer(keyReference: MockCryptoSecret(id: UUID()), keyId: "mockKeyId")
        let requirement1 = MockPresentationExchangeRequirement(inputDescriptorId: "1")
        let descriptor1 = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement1)
        
        let requirement2 = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        let descriptor2 = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement2)
        
        let requirement3 = MockPresentationExchangeRequirement(inputDescriptorId: "3")
        let descriptor3 = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement3)
        
        let index = 1
        
        let formatter = VerifiablePresentationFormatter(signer: MockSigner(doesSignThrow: false))
        let builder = VerifiablePresentationBuilder(index: index, formatter: formatter)
        builder.add(partialInputDescriptor: descriptor1)
        builder.add(partialInputDescriptor: descriptor2)
        builder.add(partialInputDescriptor: descriptor3)
        
        // Act
        let result = try builder.buildVerifiablePresentation(audience: mockAudience,
                                                             nonce: mockNonce,
                                                             identifier: mockIdentifier,
                                                             signingKey: mockKey)
        
        // Assert
        XCTAssertEqual(result.content.audience, mockAudience)
        XCTAssertEqual(result.content.issuerOfVp, mockIdentifier)
        XCTAssertEqual(result.content.nonce, mockNonce)
        XCTAssertEqual(result.content.verifiablePresentation.verifiableCredential,
                       [descriptor1.serializedVerifiedId, descriptor2.serializedVerifiedId, descriptor3.serializedVerifiedId])
    }
    
    func testBuildVerifiablePresentation_WithFormatterThrowing_ThrowsError() throws
    {
        // Arrange
        let mockAudience = "mock audience"
        let mockNonce = "mock nonce"
        let mockIdentifier = "mock identifier"
        let mockKey = KeyContainer(keyReference: MockCryptoSecret(id: UUID()), keyId: "mockKeyId")
        let inputReq = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        let input = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: inputReq)
        
        let index = 1
        
        let formatter = VerifiablePresentationFormatter(signer: MockSigner(doesSignThrow: true))
        let builder = VerifiablePresentationBuilder(index: index, formatter: formatter)
        builder.add(partialInputDescriptor: input)
        
        // Act / Assert
        XCTAssertThrowsError(try builder.buildVerifiablePresentation(audience: mockAudience,
                                                                     nonce: mockNonce,
                                                                     identifier: mockIdentifier,
                                                                     signingKey: mockKey)) { error in
            XCTAssert(error is MockSigner.ExpectedError)
            XCTAssertEqual((error as? MockSigner.ExpectedError), .SignExpectedToThrow)
        }
    }
}
