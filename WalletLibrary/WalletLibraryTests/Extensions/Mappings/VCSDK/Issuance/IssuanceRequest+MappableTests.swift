/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class IssuanceRequestMappingTests: XCTestCase {
    
    enum ExpectedError: Error {
        case expectedToBeUnableToMapAttestationsDescriptor
        case expectedToBeUnableToMapLinkedDomainResult
        case expectedToBeUnableToMapCardDisplayDescriptor
    }
    
    func testMap_WithNilAttestations_ThrowsError() throws {
        // Arrange
        let mockSignedContract = createMockSignedContract()
        let issuanceRequest = IssuanceRequest(from: mockSignedContract, linkedDomainResult: .linkedDomainMissing)
        let mapper = MockMapper()
        
        // Act
        XCTAssertThrowsError(try mapper.map(issuanceRequest)) { error in
            // Assert
            XCTAssert(error is MappingError)
            XCTAssertEqual(error as? MappingError,
                           .PropertyNotPresent(property: "attestations", in: String(describing: IssuanceRequest.self)))
        }
    }
    
    func testMap_WhenAttestationsMappingThrowsError_ThrowsError() throws {
        // Arrange
        let attestations = AttestationsDescriptor(accessTokens: [])
        let signedContract = createMockSignedContract(attestations: attestations)
        let issuanceRequest = IssuanceRequest(from: signedContract, linkedDomainResult: .linkedDomainMissing)

        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is AttestationsDescriptor {
                throw ExpectedError.expectedToBeUnableToMapAttestationsDescriptor
            }

            return nil
        }

        let mapper = MockMapper(mockResults: mockResults)

        // Act
        XCTAssertThrowsError(try mapper.map(issuanceRequest)) { error in
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, .expectedToBeUnableToMapAttestationsDescriptor)
        }
    }
    
    func testMap_WhenLinkedDomainThrowsError_ThrowsError() throws {
        // Arrange
        let mockRequirement = MockRequirement(id: "mock requirement")
        let attestations = AttestationsDescriptor(accessTokens: [])
        let signedContract = createMockSignedContract(attestations: attestations)
        let issuanceRequest = IssuanceRequest(from: signedContract, linkedDomainResult: .linkedDomainMissing)

        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is AttestationsDescriptor {
                return mockRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                throw ExpectedError.expectedToBeUnableToMapLinkedDomainResult
            }

            return nil
        }

        let mapper = MockMapper(mockResults: mockResults)

        // Act
        XCTAssertThrowsError(try mapper.map(issuanceRequest)) { error in
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, .expectedToBeUnableToMapLinkedDomainResult)
        }
    }
    
    func testMap_WhenCardDisplayDescriptorMappingThrowsError_ThrowsError() throws {
        // Arrange
        let mockRequirement = MockRequirement(id: "mock requirement")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let attestations = AttestationsDescriptor(accessTokens: [])
        let signedContract = createMockSignedContract(attestations: attestations)
        let issuanceRequest = IssuanceRequest(from: signedContract, linkedDomainResult: .linkedDomainMissing)

        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is AttestationsDescriptor {
                return mockRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                return mockRootOfTrust
            }
            
            if objectToBeMapped is CardDisplayDescriptor {
                throw ExpectedError.expectedToBeUnableToMapCardDisplayDescriptor
            }

            return nil
        }

        let mapper = MockMapper(mockResults: mockResults)

        // Act
        XCTAssertThrowsError(try mapper.map(issuanceRequest)) { error in
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, .expectedToBeUnableToMapCardDisplayDescriptor)
        }
    }
    
    func testMap_WithValidInput_ReturnsVerifiedIdRequestContent() throws {
        // Arrange
        let mockRequirement = MockRequirement(id: "mock requirement")
        let mockRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let mockVerifiedIdStyle = MockVerifiedIdStyle()
        let attestations = AttestationsDescriptor(accessTokens: [])
        let signedContract = createMockSignedContract(attestations: attestations)
        let issuanceRequest = IssuanceRequest(from: signedContract, linkedDomainResult: .linkedDomainMissing)

        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is AttestationsDescriptor {
                return mockRequirement
            }
            
            if objectToBeMapped is LinkedDomainResult {
                return mockRootOfTrust
            }
            
            if objectToBeMapped is CardDisplayDescriptor {
                return mockVerifiedIdStyle
            }

            return nil
        }

        let mapper = MockMapper(mockResults: mockResults)

        // Act
        let actualResult = try mapper.map(issuanceRequest)
        
        // Assert
        XCTAssertEqual(actualResult.style.name, "mock issuer")
        XCTAssert(actualResult.style is VerifiedIdManifestIssuerStyle)
        XCTAssertEqual((actualResult.style as? VerifiedIdManifestIssuerStyle)?.requestTitle, "mock title")
        XCTAssertEqual((actualResult.style as? VerifiedIdManifestIssuerStyle)?.requestInstructions, "mock purpose")
        XCTAssertEqual(actualResult.style.name, "mock issuer")
        XCTAssertEqual(actualResult.rootOfTrust, mockRootOfTrust)
        XCTAssertEqual(actualResult.requirement as? MockRequirement, mockRequirement)
        XCTAssertEqual(actualResult.verifiedIdStyle as? MockVerifiedIdStyle, mockVerifiedIdStyle)
    }
    
    private func createMockSignedContract(attestations: AttestationsDescriptor? = nil) -> SignedContract {
        let mockCardDisplay = CardDisplayDescriptor(title: "mock title",
                                                    issuedBy: "mock issuer",
                                                    backgroundColor: "mock background color",
                                                    textColor: "mock text color",
                                                    logo: nil,
                                                    cardDescription: "mock description")
        let mockConsentDisplay = ConsentDisplayDescriptor(title: "mock title",
                                                          instructions: "mock purpose")
        let mockDisplayDescriptor = DisplayDescriptor(id: nil,
                                                      locale: nil,
                                                      contract: nil,
                                                      card: mockCardDisplay,
                                                      consent: mockConsentDisplay,
                                                      claims: [:])
        let mockContractInputDescriptor = ContractInputDescriptor(credentialIssuer: "mock credential issuer",
                                                                  issuer: "mock issuer",
                                                                  attestations: attestations)
        let mockContract = Contract(id: "mockContract",
                                    display: mockDisplayDescriptor,
                                    input: mockContractInputDescriptor)
        
        return SignedContract(headers: Header(), content: mockContract)!
    }
}
