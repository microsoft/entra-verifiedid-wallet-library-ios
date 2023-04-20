/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class AttestationsDescriptorMappingTests: XCTestCase {
    
    enum MockError: Error {
        case expectedToBeUnableToMapAccessTokenDescriptor
        case expectedToBeUnableToMapIdTokenDescriptor
        case expectedToBeUnableToMapPresentationDescriptor
        case expectedToBeUnableToMapSelfIssuedClaimsDescriptor
    }

    func testMap_WithOnlyOneAccessTokenRequirement_ReturnsRequirement() throws {
        // Arrange
        let expectedAccessTokenRequirement = AccessTokenRequirement(encrypted: false,
                                                                    required: true,
                                                                    configuration: "mock configuration",
                                                                    clientId: "mock client id",
                                                                    resourceId: "mock resource id",
                                                                    scope: "mock scope")
        let mockAccessTokenDescriptor = AccessTokenDescriptor()
        let attestations = AttestationsDescriptor(accessTokens: [mockAccessTokenDescriptor])
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is AccessTokenDescriptor {
                return expectedAccessTokenRequirement
            }
            
            return nil
        }
        
        let mapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mapper.map(attestations)
        
        // Assert
        XCTAssert(actualResult is AccessTokenRequirement)
        XCTAssertIdentical(actualResult as AnyObject, expectedAccessTokenRequirement as AnyObject)
    }

    func testMap_WhenAccessTokenRequirementMappingThrows_ThrowsError() throws {
        // Arrange
        let mockAccessTokenDescriptor = AccessTokenDescriptor()
        let attestations = AttestationsDescriptor(accessTokens: [mockAccessTokenDescriptor])
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is AccessTokenDescriptor {
                throw MockError.expectedToBeUnableToMapAccessTokenDescriptor
            }
            
            return nil
        }
        
        let mapper = MockMapper(mockResults: mockResults)
        
        // Act
        XCTAssertThrowsError(try mapper.map(attestations)) { error in
            // Assert
            XCTAssert(error is MockError)
            XCTAssertEqual(error as? MockError, .expectedToBeUnableToMapAccessTokenDescriptor)
        }
    }

    func testMap_WithOnlyOneIdTokenRequirement_ReturnsRequirement() throws {
        // Arrange
        let expectedIdTokenRequirement = IdTokenRequirement(encrypted: false,
                                                                required: true,
                                                                configuration: URL(string: "https://test.com")!,
                                                                clientId: "mock client id",
                                                                redirectUri: "mock redirect uri",
                                                                scope: "mock scope")
        let mockIdTokenDescriptor = IdTokenDescriptor(claims: [], configuration: "mock config", clientID: "mock client id")
        let attestations = AttestationsDescriptor(idTokens: [mockIdTokenDescriptor])
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is IdTokenDescriptor {
                return expectedIdTokenRequirement
            }
            
            return nil
        }
        
        let mapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mapper.map(attestations)
        
        // Assert
        XCTAssert(actualResult is IdTokenRequirement)
        XCTAssertIdentical(actualResult as AnyObject, expectedIdTokenRequirement as AnyObject)
    }
    
    func testMap_WhenIdTokenRequirementMappingThrows_ThrowsError() throws {
        // Arrange
        let mockIdTokenDescriptor = IdTokenDescriptor(claims: [], configuration: "mock config", clientID: "mock client id")
        let attestations = AttestationsDescriptor(idTokens: [mockIdTokenDescriptor])
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is IdTokenDescriptor {
                throw MockError.expectedToBeUnableToMapIdTokenDescriptor
            }
            
            return nil
        }
        
        let mapper = MockMapper(mockResults: mockResults)
        
        // Act
        XCTAssertThrowsError(try mapper.map(attestations)) { error in
            // Assert
            XCTAssert(error is MockError)
            XCTAssertEqual(error as? MockError, .expectedToBeUnableToMapIdTokenDescriptor)
        }
    }
    
    func testMap_WithOnlyOneVerifiedIdRequirement_ReturnsRequirement() throws {
        // Arrange
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: true,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                                        constraintOperator: .ALL))
        let mockPresentationDescriptor = PresentationDescriptor(claims: [],
                                                                credentialType: "mock type")
        let attestations = AttestationsDescriptor(presentations: [mockPresentationDescriptor])
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is PresentationDescriptor {
                return expectedVerifiedIdRequirement
            }
            
            return nil
        }
        
        let mapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mapper.map(attestations)
        
        // Assert
        XCTAssert(actualResult is VerifiedIdRequirement)
        XCTAssertIdentical(actualResult as AnyObject, expectedVerifiedIdRequirement as AnyObject)
    }

    func testMap_WhenVerifiedIdRequirementMappingThrows_ThrowsError() throws {
        // Arrange
        let mockPresentationDescriptor = PresentationDescriptor(claims: [],
                                                                credentialType: "mock type")
        let attestations = AttestationsDescriptor(presentations: [mockPresentationDescriptor])
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is PresentationDescriptor {
                throw MockError.expectedToBeUnableToMapPresentationDescriptor
            }
            
            return nil
        }
        
        let mapper = MockMapper(mockResults: mockResults)
        
        // Act
        XCTAssertThrowsError(try mapper.map(attestations)) { error in
            // Assert
            XCTAssert(error is MockError)
            XCTAssertEqual(error as? MockError, .expectedToBeUnableToMapPresentationDescriptor)
        }
    }
    
    func testMap_WithOnlyOneSelfAttestedRequirement_ReturnsRequirement() throws {
        // Arrange
        let expectedSelfAttestedClaimRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                                required: true,
                                                                                claim: "mock claim")
        let mockSelfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor()
        let attestations = AttestationsDescriptor(selfIssued: mockSelfIssuedClaimsDescriptor)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is SelfIssuedClaimsDescriptor {
                return expectedSelfAttestedClaimRequirement
            }
            
            return nil
        }
        
        let mapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mapper.map(attestations)
        
        // Assert
        XCTAssert(actualResult is SelfAttestedClaimRequirement)
        XCTAssertIdentical(actualResult as AnyObject, expectedSelfAttestedClaimRequirement as AnyObject)
    }
    
    func testMap_WhenSelfAttestedRequirementMappingThrows_ThrowsError() throws {
        // Arrange
        let mockSelfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor()
        let attestations = AttestationsDescriptor(selfIssued: mockSelfIssuedClaimsDescriptor)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is SelfIssuedClaimsDescriptor {
                throw MockError.expectedToBeUnableToMapSelfIssuedClaimsDescriptor
            }
            
            return nil
        }
        
        let mapper = MockMapper(mockResults: mockResults)
        
        // Act
        XCTAssertThrowsError(try mapper.map(attestations)) { error in
            // Assert
            XCTAssert(error is MockError)
            XCTAssertEqual(error as? MockError, .expectedToBeUnableToMapSelfIssuedClaimsDescriptor)
        }
    }
    
    func testMap_WithDifferentMultipleRequirements_ReturnsGroupRequirement() throws {
        // Arrange
        let expectedSelfAttestedClaimRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                                required: true,
                                                                                claim: "mock claim")
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: true,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                                        constraintOperator: .ALL))
        let expectedIdTokenRequirement = IdTokenRequirement(encrypted: false,
                                                                required: true,
                                                                configuration: URL(string: "https://test.com")!,
                                                                clientId: "mock client id",
                                                                redirectUri: "mock redirect uri",
                                                                scope: "mock scope")
        let expectedAccessTokenRequirement = AccessTokenRequirement(encrypted: false,
                                                                    required: true,
                                                                    configuration: "mock configuration",
                                                                    clientId: "mock client id",
                                                                    resourceId: "mock resource id",
                                                                    scope: "mock scope")
        
        let mockSelfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor()
        let mockPresentationDescriptor = PresentationDescriptor(claims: [],
                                                                credentialType: "mock type")
        let mockIdTokenDescriptor = IdTokenDescriptor(claims: [], configuration: "mock config", clientID: "mock client id")
        let mockAccessTokenDescriptor = AccessTokenDescriptor()
        
        let attestations = AttestationsDescriptor(selfIssued: mockSelfIssuedClaimsDescriptor,
                                                  presentations: [mockPresentationDescriptor],
                                                  idTokens: [mockIdTokenDescriptor],
                                                  accessTokens: [mockAccessTokenDescriptor])
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is SelfIssuedClaimsDescriptor {
                return expectedSelfAttestedClaimRequirement
            }
            
            if objectToBeMapped is PresentationDescriptor {
                return expectedVerifiedIdRequirement
            }
            
            if objectToBeMapped is IdTokenDescriptor {
                return expectedIdTokenRequirement
            }
            
            if objectToBeMapped is AccessTokenDescriptor {
                return expectedAccessTokenRequirement
            }
            
            return nil
        }
        
        let mapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mapper.map(attestations)
        
        // Assert
        XCTAssert(actualResult is GroupRequirement)
        XCTAssertEqual((actualResult as? GroupRequirement)?.requirements.count, 4)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements.first as AnyObject, expectedAccessTokenRequirement)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements[1] as AnyObject, expectedIdTokenRequirement)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements[2] as AnyObject, expectedVerifiedIdRequirement)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements[3] as AnyObject, expectedSelfAttestedClaimRequirement)
    }
    
    func testMap_WithTwoVerifiedIdRequirementAndOneEveryOtherRequirement_ReturnsGroupRequirement() throws {
        // Arrange
        let expectedSelfAttestedClaimRequirement = SelfAttestedClaimRequirement(encrypted: false,
                                                                                required: true,
                                                                                claim: "mock claim")
        let expectedVerifiedIdRequirement = VerifiedIdRequirement(encrypted: false,
                                                                  required: true,
                                                                  types: [],
                                                                  purpose: nil,
                                                                  issuanceOptions: [],
                                                                  id: nil,
                                                                  constraint: GroupConstraint(constraints: [],
                                                                                                        constraintOperator: .ALL))
        let expectedIdTokenRequirement = IdTokenRequirement(encrypted: false,
                                                                required: true,
                                                                configuration: URL(string: "https://test.com")!,
                                                                clientId: "mock client id",
                                                                redirectUri: "mock redirect uri",
                                                                scope: "mock scope")
        let expectedAccessTokenRequirement = AccessTokenRequirement(encrypted: false,
                                                                    required: true,
                                                                    configuration: "mock configuration",
                                                                    clientId: "mock client id",
                                                                    resourceId: "mock resource id",
                                                                    scope: "mock scope")
        
        let mockSelfIssuedClaimsDescriptor = SelfIssuedClaimsDescriptor()
        let mockPresentationDescriptor = PresentationDescriptor(claims: [],
                                                                credentialType: "mock type")
        let mockIdTokenDescriptor = IdTokenDescriptor(claims: [], configuration: "mock config", clientID: "mock client id")
        let mockAccessTokenDescriptor = AccessTokenDescriptor()
        
        let attestations = AttestationsDescriptor(selfIssued: mockSelfIssuedClaimsDescriptor,
                                                  presentations: [mockPresentationDescriptor, mockPresentationDescriptor],
                                                  idTokens: [mockIdTokenDescriptor],
                                                  accessTokens: [mockAccessTokenDescriptor])
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is SelfIssuedClaimsDescriptor {
                return expectedSelfAttestedClaimRequirement
            }
            
            if objectToBeMapped is PresentationDescriptor {
                return expectedVerifiedIdRequirement
            }
            
            if objectToBeMapped is IdTokenDescriptor {
                return expectedIdTokenRequirement
            }
            
            if objectToBeMapped is AccessTokenDescriptor {
                return expectedAccessTokenRequirement
            }
            
            return nil
        }
        
        let mapper = MockMapper(mockResults: mockResults)
        
        // Act
        let actualResult = try mapper.map(attestations)
        
        // Assert
        XCTAssert(actualResult is GroupRequirement)
        XCTAssertEqual((actualResult as? GroupRequirement)?.requirements.count, 5)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements.first as AnyObject, expectedAccessTokenRequirement)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements[1] as AnyObject, expectedIdTokenRequirement)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements[2] as AnyObject, expectedVerifiedIdRequirement)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements[3] as AnyObject, expectedVerifiedIdRequirement)
        XCTAssertIdentical((actualResult as? GroupRequirement)?.requirements[4] as AnyObject, expectedSelfAttestedClaimRequirement)
    }
    
    func testMap_WhenAllNilRequirementInAttestations_ThrowsError() throws {
        // Arrange
        let attestations = AttestationsDescriptor()
        
        let mapper = MockMapper()
        
        // Act
        XCTAssertThrowsError(try mapper.map(attestations)) { error in
            // Assert
            XCTAssert(error is AttestationsDescriptorMappingError)
            XCTAssertEqual(error as? AttestationsDescriptorMappingError, .noRequirementsPresent)
        }
    }
    
    func testMap_WhenEmptyRequirementInAttestations_ThrowsError() throws {
        // Arrange
        let attestations = AttestationsDescriptor(selfIssued: nil,
                                                  presentations: [],
                                                  idTokens: [],
                                                  accessTokens: [])
        
        let mapper = MockMapper()
        
        // Act
        XCTAssertThrowsError(try mapper.map(attestations)) { error in
            // Assert
            XCTAssert(error is AttestationsDescriptorMappingError)
            XCTAssertEqual(error as? AttestationsDescriptorMappingError, .noRequirementsPresent)
        }
    }
}
