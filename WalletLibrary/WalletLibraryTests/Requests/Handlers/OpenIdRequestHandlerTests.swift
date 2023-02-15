/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import VCEntities
@testable import WalletLibrary

class OpenIdRequestHandlerTests: XCTestCase {
    
    enum ExpectedError: Error, Equatable {
        case expectedToBeThrown
        case expectedToBeUnableToResolveContract
        case expectedToBeUnableToMapRawContractToVerifiedIdContent
    }
    
    func testHandlePresentationRequest_WithRawPresentationRequest_ReturnsVerifiedIdRequest() async throws {
        
        // Arrange
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = MockRequirement(id: "mockRequirement324")
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = VerifiedIdRequestContent(style: expectedStyle,
                                                       requirement: expectedRequirement,
                                                       rootOfTrust: expectedRootOfTrust)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data())
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestHandler(configuration: configuration, contractResolver: MockContractResolver())
        
        // Act
        let actualRequest = try await handler.handleRequest(from: mockRawRequest)
        
        // Assert
        XCTAssert(actualRequest is OpenIdPresentationRequest)
        XCTAssertEqual(actualRequest.style as? MockRequesterStyle, expectedStyle)
        XCTAssertEqual(actualRequest.requirement as? MockRequirement, expectedRequirement)
        XCTAssertEqual(actualRequest.rootOfTrust.source, expectedRootOfTrust.source)
        XCTAssert(actualRequest.rootOfTrust.verified)
    }
    
    func testHandlePresentationRequest_WithPresentationRequestInvalidMapping_ThrowsError() async throws {
        
        // Arrange
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                throw ExpectedError.expectedToBeThrown
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data())
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestHandler(configuration: configuration, contractResolver: MockContractResolver())
        
        // Act
        do {
            let _ = try await handler.handleRequest(from: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, ExpectedError.expectedToBeThrown)
        }
    }
    
    func testHandleIssuanceRequest_WithUnableToCaseRequirementToVerifiedIdRequirement_ThrowsError() async throws {
        
        // Arrange
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = MockRequirement(id: "test")
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = VerifiedIdRequestContent(style: expectedStyle,
                                                       requirement: expectedRequirement,
                                                       rootOfTrust: expectedRootOfTrust)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestHandler(configuration: configuration, contractResolver: MockContractResolver())
        
        // Act
        do {
            let _ = try await handler.handleRequest(from: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is OpenIdRequestHandlerError)
            XCTAssertEqual(error as? OpenIdRequestHandlerError, OpenIdRequestHandlerError.unableToCaseRequirementToVerifiedIdRequirement)
        }
    }
    
    func testHandleIssuanceRequest_WithNoIssuanceOptionsOnPresentationRequest_ThrowsError() async throws {
        
        // Arrange
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [])
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = VerifiedIdRequestContent(style: expectedStyle,
                                                       requirement: expectedRequirement,
                                                       rootOfTrust: expectedRootOfTrust)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestHandler(configuration: configuration, contractResolver: MockContractResolver())
        
        // Act
        do {
            let _ = try await handler.handleRequest(from: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is OpenIdRequestHandlerError)
            XCTAssertEqual(error as? OpenIdRequestHandlerError, OpenIdRequestHandlerError.noIssuanceOptionsPresentToCreateIssuanceRequest)
        }
    }
    
    func testHandleIssuanceRequest_WithIssuanceOptionInvalidType_ThrowsError() async throws {
        
        // Arrange
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [MockInput(mockData: "")])
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = VerifiedIdRequestContent(style: expectedStyle,
                                                       requirement: expectedRequirement,
                                                       rootOfTrust: expectedRootOfTrust)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestHandler(configuration: configuration, contractResolver: MockContractResolver())
        
        // Act
        do {
            let _ = try await handler.handleRequest(from: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is OpenIdRequestHandlerError)
            XCTAssertEqual(error as? OpenIdRequestHandlerError, OpenIdRequestHandlerError.noIssuanceOptionsPresentToCreateIssuanceRequest)
        }
    }
    
    func testHandleIssuanceRequest_WhenUnableToResolveContract_ThrowsError() async throws {
        
        // Arrange
        let issuanceOptionURL = URL(string: "https://test.com")!
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [VerifiedIdRequestURL(url: issuanceOptionURL)])
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = VerifiedIdRequestContent(style: expectedStyle,
                                                       requirement: expectedRequirement,
                                                       rootOfTrust: expectedRootOfTrust)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        func mockResolveContract(url: String) throws -> any RawContract {
            throw ExpectedError.expectedToBeUnableToResolveContract
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestHandler(configuration: configuration,
                                           contractResolver: MockContractResolver(mockGetRequestCallback: mockResolveContract))
        
        // Act
        do {
            let _ = try await handler.handleRequest(from: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, ExpectedError.expectedToBeUnableToResolveContract)
        }
    }
    
    func testHandleIssuanceRequest_WhenUnableToMapRawContractToVerifiedIdRequestContent_ThrowsError() async throws {
        
        // Arrange
        let issuanceOptionURL = URL(string: "https://test.com")!
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [VerifiedIdRequestURL(url: issuanceOptionURL)])
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = VerifiedIdRequestContent(style: expectedStyle,
                                                       requirement: expectedRequirement,
                                                       rootOfTrust: expectedRootOfTrust)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            if objectToBeMapped is MockRawContract {
                throw ExpectedError.expectedToBeUnableToMapRawContractToVerifiedIdContent
            }
            
            return nil
        }
        
        func mockResolveContract(url: String) throws -> any RawContract {
            return MockRawContract(id: "testContract345")
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestHandler(configuration: configuration,
                                           contractResolver: MockContractResolver(mockGetRequestCallback: mockResolveContract))
        
        // Act
        do {
            let _ = try await handler.handleRequest(from: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, ExpectedError.expectedToBeUnableToMapRawContractToVerifiedIdContent)
        }
    }
    
    func testHandleIssuanceRequest_WithValidContract_ReturnsVerifiedIdIssuanceRequest() async throws {
        
        // Arrange
        let issuanceOptionURL = URL(string: "https://test.com")!
        let expectedPresentationStyle = MockRequesterStyle(requester: "mock requester")
        let expectedPresentationRequirement = VerifiedIdRequirement(encrypted: false,
                                                                    required: true,
                                                                    types: [],
                                                                    purpose: nil,
                                                                    issuanceOptions: [VerifiedIdRequestURL(url: issuanceOptionURL)])
        let expectedPresentationRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedPresentationContent = VerifiedIdRequestContent(style: expectedPresentationStyle,
                                                                   requirement: expectedPresentationRequirement,
                                                                   rootOfTrust: expectedPresentationRootOfTrust)
        
        let expectedIssuanceStyle = MockRequesterStyle(requester: "mock issuer")
        let expectedIssuanceRequirement = MockRequirement(id: "mockRequirement23535")
        let expectedIssuanceRootOfTrust = RootOfTrust(verified: true, source: "mock issuer source")
        let expectedIssuanceContent = VerifiedIdRequestContent(style: expectedIssuanceStyle,
                                                               requirement: expectedIssuanceRequirement,
                                                               rootOfTrust: expectedIssuanceRootOfTrust)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedPresentationContent
            }
            
            if objectToBeMapped is MockRawContract {
                return expectedIssuanceContent
            }
            
            return nil
        }
        
        func mockResolveContract(url: String) throws -> any RawContract {
            return MockRawContract(id: "testContract345")
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestHandler(configuration: configuration,
                                           contractResolver: MockContractResolver(mockGetRequestCallback: mockResolveContract))
        
        // Act
        let actualRequest = try await handler.handleRequest(from: mockRawRequest)
        
        // Assert
        XCTAssert(actualRequest is ContractIssuanceRequest)
        XCTAssertEqual(actualRequest.style as? MockRequesterStyle, expectedIssuanceStyle)
        XCTAssertEqual(actualRequest.requirement as? MockRequirement, expectedIssuanceRequirement)
        XCTAssertEqual(actualRequest.rootOfTrust.source, expectedIssuanceRootOfTrust.source)
        XCTAssert(actualRequest.rootOfTrust.verified)
        
    }
}
