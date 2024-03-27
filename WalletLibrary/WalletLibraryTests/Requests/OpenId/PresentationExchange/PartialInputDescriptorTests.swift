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
        let descriptor = PartialInputDescriptor(rawVC: "mockVC", peRequirement: requirement)
        
        let inputReq = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        let input = PartialInputDescriptor(rawVC: "mockVC", peRequirement: inputReq)
        
        // Act / Assert
        XCTAssertFalse(descriptor.isCompatibleWith(partialInputDescriptor: input))
    }
    
    func testIsCompatibleWith_WithSelfNotCompatWithInput_ReturnsFalse() throws
    {
        // Arrange
        let requirement = MockPresentationExchangeRequirement(inputDescriptorId: "1",
                                                              exclusivePresentationWith: ["3", "4"])
        let descriptor = PartialInputDescriptor(rawVC: "mockVC", peRequirement: requirement)
        
        let inputReq = MockPresentationExchangeRequirement(inputDescriptorId: "2", 
                                                           exclusivePresentationWith: ["3", "1"])
        let input = PartialInputDescriptor(rawVC: "mockVC", peRequirement: inputReq)
        
        // Act / Assert
        XCTAssertFalse(descriptor.isCompatibleWith(partialInputDescriptor: input))
    }
    
    func testIsCompatibleWith_WithCompatInput_ReturnsTrue() throws
    {
        // Arrange
        let requirement = MockPresentationExchangeRequirement(inputDescriptorId: "1",
                                                              exclusivePresentationWith: ["3", "4"])
        let descriptor = PartialInputDescriptor(rawVC: "mockVC", peRequirement: requirement)
        
        let inputReq = MockPresentationExchangeRequirement(inputDescriptorId: "2")
        let input = PartialInputDescriptor(rawVC: "mockVC", peRequirement: inputReq)
        
        // Act / Assert
        XCTAssert(descriptor.isCompatibleWith(partialInputDescriptor: input))
    }
}
