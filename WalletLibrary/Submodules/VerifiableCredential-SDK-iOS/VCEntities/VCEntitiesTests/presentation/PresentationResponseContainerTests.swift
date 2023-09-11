/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class PresentationResponseContainerTests: XCTestCase {
    
    func testAddVerifiableCredential_WithEmptyVpRequests_ThrowsError() throws {
        // Arrange
        var container = try PresentationResponseContainer.mock(using: [])
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: [],
                                                                         claims: [:],
                                                                         issuer: "mock issuer")
        
        // Act
        XCTAssertThrowsError(try container.addVerifiableCredential(id: "mock id", vc: mockVC)) { error in
            // Assert
            XCTAssert(error is PresentationResponseError)
            XCTAssertEqual(error as? PresentationResponseError,
                           .noVerifiablePresentationRequestsInRequest)
        }
    }
    
    func testAddVerifiableCredential_WithMalformedVpRequest_ThrowsError() throws {
        // Arrange
        let vpRequest = RequestedVPToken(presentationDefinition: nil)
        var container = try PresentationResponseContainer.mock(using: [vpRequest])
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: [],
                                                                         claims: [:],
                                                                         issuer: "mock issuer")
        
        // Act
        XCTAssertThrowsError(try container.addVerifiableCredential(id: "mock id", vc: mockVC)) { error in
            // Assert
            XCTAssert(error is PresentationResponseError)
            XCTAssertEqual(error as? PresentationResponseError,
                           .noPresentationDefinitionInVerifiablePresentationRequest)
        }
    }
    
    func testAddVerifiableCredential_WithNoPresentationDefinitionIdDefined_ThrowsError() throws {
        // Arrange
        let presentationDefinition = PresentationDefinition(id: nil,
                                                            inputDescriptors: [],
                                                            issuance: [])
        let vpRequest = RequestedVPToken(presentationDefinition: presentationDefinition)
        var container = try PresentationResponseContainer.mock(using: [vpRequest])
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: [],
                                                                         claims: [:],
                                                                         issuer: "mock issuer")
        
        // Act
        XCTAssertThrowsError(try container.addVerifiableCredential(id: "mock id", vc: mockVC)) { error in
            // Assert
            XCTAssert(error is PresentationResponseError)
            XCTAssertEqual(error as? PresentationResponseError,
                           .noPresentationDefinitionInVerifiablePresentationRequest)
        }
    }
    
    func testAddVerifiableCredential_WithNoMatchingInputDescriptor_ThrowsError() throws {
        // Arrange
        let notMatchingId = "should not match"
        let inputDescriptor = createInputDescriptor(withId: notMatchingId)
        let presentationDefinition = PresentationDefinition(id: "mock presentation id",
                                                            inputDescriptors: [inputDescriptor],
                                                            issuance: [])
        let vpRequest = RequestedVPToken(presentationDefinition: presentationDefinition)
        var container = try PresentationResponseContainer.mock(using: [vpRequest])
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: [],
                                                                         claims: [:],
                                                                         issuer: "mock issuer")
        
        // Act
        XCTAssertThrowsError(try container.addVerifiableCredential(id: "mock id", vc: mockVC)) { error in
            // Assert
            XCTAssert(error is PresentationResponseError)
            XCTAssertEqual(error as? PresentationResponseError,
                           .noInputDescriptorMatchesGivenId)
        }
    }
    
    func testAddVerifiableCredential_WithMatchingInputDecriptor_AddsVC() throws {
        // Arrange
        let presentationDefinitionId = "presentation definition id"
        let id = "requested id"
        let inputDescriptor = createInputDescriptor(withId: id)
        let presentationDefinition = PresentationDefinition(id: presentationDefinitionId,
                                                            inputDescriptors: [inputDescriptor],
                                                            issuance: [])
        let vpRequest = RequestedVPToken(presentationDefinition: presentationDefinition)
        var container = try PresentationResponseContainer.mock(using: [vpRequest])
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: [],
                                                                         claims: [:],
                                                                         issuer: "mock issuer")
        
        // Act
        try container.addVerifiableCredential(id: id, vc: mockVC)
        
        // Assert
        XCTAssertEqual(container.requestVCMap[presentationDefinitionId]?.count, 1)
        let mapping = container.requestVCMap[presentationDefinitionId]
        XCTAssertEqual(mapping?.first?.inputDescriptorId, id)
        XCTAssertEqual(try mapping?.first?.vc.serialize(), try mockVC.serialize())
    }
    
    func testAddVerifiableCredential_WithMatchingInputDecriptorAndUpdatesValue_AddsVC() throws {
        // Arrange
        let presentationDefinitionId = "presentation definition id"
        let id = "requested id"
        let id2 = "requested id 2"
        let inputDescriptor1 = createInputDescriptor(withId: id)
        let inputDescriptor2 = createInputDescriptor(withId: id2)
        let presentationDefinition = PresentationDefinition(id: presentationDefinitionId,
                                                            inputDescriptors: [inputDescriptor1, inputDescriptor2],
                                                            issuance: [])
        let vpRequest = RequestedVPToken(presentationDefinition: presentationDefinition)
        var container = try PresentationResponseContainer.mock(using: [vpRequest])
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: [],
                                                                         claims: [:],
                                                                         issuer: "mock issuer")
        let mockVC2 = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: [],
                                                                          claims: [:],
                                                                          issuer: "mock issuer 2")
        
        // Act
        try container.addVerifiableCredential(id: id, vc: mockVC)
        try container.addVerifiableCredential(id: id2, vc: mockVC2)
        
        // Assert
        XCTAssertEqual(container.requestVCMap[presentationDefinitionId]?.count, 2)
        let mapping = container.requestVCMap[presentationDefinitionId]
        XCTAssertEqual(mapping?.first?.inputDescriptorId, id)
        XCTAssertEqual(try mapping?.first?.vc.serialize(), try mockVC.serialize())
        XCTAssertEqual(mapping?[1].inputDescriptorId, id2)
        XCTAssertEqual(try mapping?[1].vc.serialize(), try mockVC2.serialize())
    }
    
    func testAddVerifiableCredential_WithMultipleVPRequests_AddsVC() throws {
        // Arrange
        let presentationDefinitionId = "presentation definition id"
        let id = "requested id"
        let inputDescriptor = createInputDescriptor(withId: id)
        let presentationDefinition = PresentationDefinition(id: presentationDefinitionId,
                                                            inputDescriptors: [inputDescriptor],
                                                            issuance: [])
        let vpRequest = RequestedVPToken(presentationDefinition: presentationDefinition)
        let presentationDefinitionId2 = "presentation definition 2"
        
        let presentationDefinition2 = PresentationDefinition(id: presentationDefinitionId2,
                                                             inputDescriptors: [],
                                                             issuance: [])
        let vpRequest2 = RequestedVPToken(presentationDefinition: presentationDefinition2)
        
        var container = try PresentationResponseContainer.mock(using: [vpRequest, vpRequest2])
        let mockVC = MockVerifiableCredentialHelper().createVCEntitiesVC(expectedTypes: [],
                                                                         claims: [:],
                                                                         issuer: "mock issuer")
        
        // Act
        try container.addVerifiableCredential(id: id, vc: mockVC)
        
        // Assert
        XCTAssertEqual(container.requestVCMap[presentationDefinitionId]?.count, 1)
        XCTAssertNil(container.requestVCMap[presentationDefinitionId2])
        let mapping = container.requestVCMap[presentationDefinitionId]
        XCTAssertEqual(mapping?.first?.inputDescriptorId, id)
        XCTAssertEqual(try mapping?.first?.vc.serialize(), try mockVC.serialize())
    }
    
    private func createInputDescriptor(withId id: String) -> PresentationInputDescriptor {
        return PresentationInputDescriptor(id: id,
                                           schema: [],
                                           issuanceMetadata: [],
                                           name: nil,
                                           purpose: nil,
                                           constraints: nil)
    }
}
