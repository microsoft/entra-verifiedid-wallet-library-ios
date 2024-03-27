/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PartialInputDescriptorTests: XCTestCase
{
    func testIsCompatibleWith_WithInputNotCompat_ReturnsFalse() throws
    {
        // Arrange
        let requirement = MockPresentationExchangeRequirement(inputDescriptorId: "1",
                                                              exclusivePresentationWith: ["2"])
        let descriptor = PartialInputDescriptor(serializedVerifiedId: "mockVC",
                                                requirement: requirement)
        
        let inputReq = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        let input = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: inputReq)
        
        // Act / Assert
        XCTAssertFalse(descriptor.isCompatibleWith(partialInputDescriptor: input))
    }
    
    func testIsCompatibleWith_WithSelfNotCompatWithInput_ReturnsFalse() throws
    {
        // Arrange
        let requirement = MockPresentationExchangeRequirement(inputDescriptorId: "1",
                                                              exclusivePresentationWith: ["3", "4"])
        let descriptor = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement)
        
        let inputReq = MockPresentationExchangeRequirement(inputDescriptorId: "2", 
                                                           exclusivePresentationWith: ["3", "1"])
        let input = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: inputReq)
        
        // Act / Assert
        XCTAssertFalse(descriptor.isCompatibleWith(partialInputDescriptor: input))
    }
    
    func testIsCompatibleWith_WithCompatInput_ReturnsTrue() throws
    {
        // Arrange
        let requirement = MockPresentationExchangeRequirement(inputDescriptorId: "1",
                                                              exclusivePresentationWith: ["3", "4"])
        let descriptor = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement)
        
        let inputReq = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        let input = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: inputReq)
        
        // Act / Assert
        XCTAssert(descriptor.isCompatibleWith(partialInputDescriptor: input))
    }
    
    func testBuildInputDescriptor_WithValidInput_ReturnsInputDescriptor() throws
    {
        // Arrange
        let mockId = "mockId"
        let requirement = MockPresentationExchangeRequirement(inputDescriptorId: mockId,
                                                              exclusivePresentationWith: ["3", "4"])
        let descriptor = PartialInputDescriptor(serializedVerifiedId: "mockVC", requirement: requirement)
        let vcIndex = 13
        let vpIndex = 42
        
        // Act
        let result = descriptor.buildInputDescriptor(vcIndex: vcIndex, vpIndex: vpIndex)
        
        // Assert
        XCTAssertEqual(result.format, "jwt_vp")
        XCTAssertEqual(result.id, mockId)
        XCTAssertEqual(result.path, "$[\(vpIndex)]")
        XCTAssertEqual(result.pathNested?.format, "jwt_vc")
        XCTAssertEqual(result.pathNested?.id, mockId)
        XCTAssertEqual(result.pathNested?.path, "$[\(vpIndex)].verifiableCredential[\(vcIndex)]")
    }
}
