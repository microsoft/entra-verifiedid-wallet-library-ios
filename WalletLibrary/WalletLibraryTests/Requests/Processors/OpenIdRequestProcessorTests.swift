/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class OpenIdRequestProcessorTests: XCTestCase {
    
    enum ExpectedError: Error, Equatable {
        case expectedToBeThrown
        case expectedToBeUnableToResolveContract
        case expectedToBeUnableToMapRawContractToVerifiedIdContent
    }
    
    func testProcessPresentationRequest_WithRawPresentationRequest_ReturnsVerifiedIdRequest() async throws {
        
        // Arrange
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = MockRequirement(id: "mockRequirement324")
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = PresentationRequestContent(style: expectedStyle,
                                                         requirement: expectedRequirement,
                                                         rootOfTrust: expectedRootOfTrust,
                                                         requestState: "mock state",
                                                         callbackUrl: URL(string: "https://test.com")!)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data())
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestProcessor(configuration: configuration,
                                           openIdResponder: MockPresentationResponder(),
                                           manifestResolver: MockManifestResolver(),
                                           verifiableCredentialRequester: MockVerifiedIdRequester())
        
        // Act
        let actualRequest = try await handler.process(rawRequest: mockRawRequest)
        
        // Assert
        XCTAssert(actualRequest is OpenIdPresentationRequest)
        XCTAssertEqual(actualRequest.style as? MockRequesterStyle, expectedStyle)
        XCTAssertEqual(actualRequest.requirement as? MockRequirement, expectedRequirement)
        XCTAssertEqual(actualRequest.rootOfTrust.source, expectedRootOfTrust.source)
        XCTAssert(actualRequest.rootOfTrust.verified)
    }
    
    func testProcessPresentationRequest_WithPresentationRequestInvalidMapping_ThrowsError() async throws {
        
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
        let handler = OpenIdRequestProcessor(configuration: configuration,
                                           openIdResponder: MockPresentationResponder(),
                                           manifestResolver: MockManifestResolver(),
                                           verifiableCredentialRequester: MockVerifiedIdRequester())
        
        // Act
        do {
            let _ = try await handler.process(rawRequest: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, ExpectedError.expectedToBeThrown)
        }
    }
    
    func testProcessPresentationRequest_WithOneExtension_ReturnsVerifiedIdRequest() async throws {
        
        // Arrange
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = MockRequirement(id: "mockRequirement324")
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = PresentationRequestContent(style: expectedStyle,
                                                         requirement: expectedRequirement,
                                                         rootOfTrust: expectedRootOfTrust,
                                                         requestState: "mock state",
                                                         callbackUrl: URL(string: "https://test.com")!)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data())
        
        // Turn on feature flag
        let previewFeatureFlags = PreviewFeatureFlags(previewFeatureFlags: [PreviewFeatureFlags.ProcessorExtensionSupport])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: mockMapper,
                                                 previewFeatureFlags: previewFeatureFlags)
        
        var processor = OpenIdRequestProcessor(configuration: configuration,
                                               openIdResponder: MockPresentationResponder(),
                                               manifestResolver: MockManifestResolver(),
                                               verifiableCredentialRequester: MockVerifiedIdRequester())
        let mockExtension = MockRequestProcessorExtension<OpenIdRequestProcessor>()
        processor.requestProcessorExtensions.append(mockExtension)
        
        // Act
        let actualRequest = try await processor.process(rawRequest: mockRawRequest)
        
        // Assert
        XCTAssert(actualRequest is OpenIdPresentationRequest)
        XCTAssertEqual(actualRequest.style as? MockRequesterStyle, expectedStyle)
        XCTAssertEqual(actualRequest.requirement as? MockRequirement, expectedRequirement)
        XCTAssertEqual(actualRequest.rootOfTrust.source, expectedRootOfTrust.source)
        XCTAssert(actualRequest.rootOfTrust.verified)
        XCTAssert(mockExtension.wasParseCalled)
    }
    
    func testProcessPresentationRequest_WithThreeExtensions_ReturnsVerifiedIdRequest() async throws {
        
        // Arrange
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = MockRequirement(id: "mockRequirement324")
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = PresentationRequestContent(style: expectedStyle,
                                                         requirement: expectedRequirement,
                                                         rootOfTrust: expectedRootOfTrust,
                                                         requestState: "mock state",
                                                         callbackUrl: URL(string: "https://test.com")!)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data())
        
        // Turn on feature flag
        let previewFeatureFlags = PreviewFeatureFlags(previewFeatureFlags: [PreviewFeatureFlags.ProcessorExtensionSupport])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: mockMapper,
                                                 previewFeatureFlags: previewFeatureFlags)
        
        var processor = OpenIdRequestProcessor(configuration: configuration,
                                               openIdResponder: MockPresentationResponder(),
                                               manifestResolver: MockManifestResolver(),
                                               verifiableCredentialRequester: MockVerifiedIdRequester())
        let mockExtension1 = MockRequestProcessorExtension<OpenIdRequestProcessor>()
        let mockExtension2 = MockRequestProcessorExtension<OpenIdRequestProcessor>()
        let mockExtensionShouldNotBeCalled = MockRequestProcessorExtension<OpenId4VCIProcessor>()
        processor.requestProcessorExtensions.append(mockExtension1)
        processor.requestProcessorExtensions.append(mockExtension2)
        processor.requestProcessorExtensions.append(mockExtensionShouldNotBeCalled)
        
        // Act
        let actualRequest = try await processor.process(rawRequest: mockRawRequest)
        
        // Assert
        XCTAssert(actualRequest is OpenIdPresentationRequest)
        XCTAssertEqual(actualRequest.style as? MockRequesterStyle, expectedStyle)
        XCTAssertEqual(actualRequest.requirement as? MockRequirement, expectedRequirement)
        XCTAssertEqual(actualRequest.rootOfTrust.source, expectedRootOfTrust.source)
        XCTAssert(actualRequest.rootOfTrust.verified)
        XCTAssert(mockExtension1.wasParseCalled)
        XCTAssert(mockExtension2.wasParseCalled)
        XCTAssertFalse(mockExtensionShouldNotBeCalled.wasParseCalled)
    }
    
    func testProcessIssuanceRequest_WithUnableToCaseRequirementToVerifiedIdRequirement_ThrowsError() async throws {
        
        // Arrange
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = MockRequirement(id: "test")
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = PresentationRequestContent(style: expectedStyle,
                                                         requirement: expectedRequirement,
                                                         rootOfTrust: expectedRootOfTrust,
                                                         requestState: "mock state",
                                                         callbackUrl: URL(string: "https://test.com")!)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestProcessor(configuration: configuration,
                                           openIdResponder: MockPresentationResponder(),
                                           manifestResolver: MockManifestResolver(),
                                           verifiableCredentialRequester: MockVerifiedIdRequester())
        
        // Act
        do {
            let _ = try await handler.process(rawRequest: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is MalformedInputError)
            XCTAssertEqual((error as? MalformedInputError)?.code, "malformed_input_error")
            XCTAssertEqual((error as? MalformedInputError)?.message, "Unsupported requirement: MockRequirement")
        }
    }
    
    func testProcessIssuanceRequest_WithNoIssuanceOptionsOnPresentationRequest_ThrowsError() async throws {
        
        // Arrange
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [],
                                                        id: nil,
                                                        constraint: GroupConstraint(constraints: [], constraintOperator: .ALL))
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = PresentationRequestContent(style: expectedStyle,
                                                         requirement: expectedRequirement,
                                                         rootOfTrust: expectedRootOfTrust,
                                                         requestState: "mock state",
                                                         callbackUrl: URL(string: "https://test.com")!)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestProcessor(configuration: configuration,
                                           openIdResponder: MockPresentationResponder(),
                                           manifestResolver: MockManifestResolver(),
                                           verifiableCredentialRequester: MockVerifiedIdRequester())
        
        // Act
        do {
            let _ = try await handler.process(rawRequest: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is MalformedInputError)
            XCTAssertEqual((error as? MalformedInputError)?.code, "malformed_input_error")
            XCTAssertEqual((error as? MalformedInputError)?.message, "No issuance options available on Presentation Request.")
        }
    }
    
    func testProcessIssuanceRequest_WithIssuanceOptionInvalidType_ThrowsError() async throws {
        
        // Arrange
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [MockInput(mockData: "")],
                                                        id: nil,
                                                        constraint: GroupConstraint(constraints: [], constraintOperator: .ALL))
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = PresentationRequestContent(style: expectedStyle,
                                                         requirement: expectedRequirement,
                                                         rootOfTrust: expectedRootOfTrust,
                                                         requestState: "mock state",
                                                         callbackUrl: URL(string: "https://test.com")!)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestProcessor(configuration: configuration,
                                           openIdResponder: MockPresentationResponder(),
                                           manifestResolver: MockManifestResolver(),
                                           verifiableCredentialRequester: MockVerifiedIdRequester())
        
        // Act
        do {
            let _ = try await handler.process(rawRequest: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is MalformedInputError)
            XCTAssertEqual((error as? MalformedInputError)?.code, "malformed_input_error")
            XCTAssertEqual((error as? MalformedInputError)?.message, "No issuance options available on Presentation Request.")
        }
    }
    
    func testProcessIssuanceRequest_WhenUnableToResolveContract_ThrowsError() async throws {
        
        // Arrange
        let issuanceOptionURL = URL(string: "https://test.com")!
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let mockState = "mock state"
        let expectedRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [VerifiedIdRequestURL(url: issuanceOptionURL)],
                                                        id: nil,
                                                        constraint: GroupConstraint(constraints: [], constraintOperator: .ALL))
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = PresentationRequestContent(style: expectedStyle,
                                                         requirement: expectedRequirement,
                                                         rootOfTrust: expectedRootOfTrust,
                                                         requestState: mockState,
                                                         callbackUrl: URL(string: "https://test.com")!)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            return nil
        }
        
        func mockResolveContract(url: String) throws -> any RawManifest {
            throw ExpectedError.expectedToBeUnableToResolveContract
        }
        
        var wasSendIssuanceResultCallbackCalled: Bool = false
        func sendIssuanceResult(response: IssuanceCompletionResponse) throws -> Void {
            XCTAssertEqual(response.code, "issuance_failed")
            XCTAssertEqual(response.details, IssuanceCompletionErrorDetails.fetchContractError.rawValue)
            XCTAssertEqual(response.state, mockState)
            wasSendIssuanceResultCallbackCalled = true
        }
        
        let mockVCRequester = MockVerifiedIdRequester(sendIssuanceResultCallback: sendIssuanceResult)
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestProcessor(configuration: configuration,
                                           openIdResponder: MockPresentationResponder(),
                                           manifestResolver: MockManifestResolver(mockGetRequestCallback: mockResolveContract),
                                           verifiableCredentialRequester: mockVCRequester)
        
        // Act
        do {
            let _ = try await handler.process(rawRequest: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(wasSendIssuanceResultCallbackCalled)
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, ExpectedError.expectedToBeUnableToResolveContract)
        }
    }
    
    func testProcessIssuanceRequest_WhenUnableToMapRawContractToVerifiedIdRequestContent_ThrowsError() async throws {
        
        // Arrange
        let issuanceOptionURL = URL(string: "https://test.com")!
        let expectedStyle = MockRequesterStyle(requester: "mock requester")
        let expectedRequirement = VerifiedIdRequirement(encrypted: false,
                                                        required: true,
                                                        types: [],
                                                        purpose: nil,
                                                        issuanceOptions: [VerifiedIdRequestURL(url: issuanceOptionURL)],
                                                        id: nil,
                                                        constraint: GroupConstraint(constraints: [], constraintOperator: .ALL))
        let expectedRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedContent = PresentationRequestContent(style: expectedStyle,
                                                         requirement: expectedRequirement,
                                                         rootOfTrust: expectedRootOfTrust,
                                                         requestState: "mock state",
                                                         callbackUrl: URL(string: "https://test.com")!)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedContent
            }
            
            if objectToBeMapped is IssuanceRequest {
                throw ExpectedError.expectedToBeUnableToMapRawContractToVerifiedIdContent
            }
            
            return nil
        }
        
        func mockResolveContract(url: String) throws -> any RawManifest {
            return createMockIssuanceRequest()
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestProcessor(configuration: configuration,
                                           openIdResponder: MockPresentationResponder(),
                                           manifestResolver: MockManifestResolver(mockGetRequestCallback: mockResolveContract),
                                           verifiableCredentialRequester: MockVerifiedIdRequester())
        
        // Act
        do {
            let _ = try await handler.process(rawRequest: mockRawRequest)
            XCTFail("handler did not throw an error.")
        } catch {
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, ExpectedError.expectedToBeUnableToMapRawContractToVerifiedIdContent)
        }
    }
    
    func testProcessIssuanceRequest_WithValidContract_ReturnsVerifiedIdIssuanceRequest() async throws {
        
        // Arrange
        let issuanceOptionURL = URL(string: "https://test.com")!
        let expectedPresentationStyle = MockRequesterStyle(requester: "mock requester")
        let mockState = "mock state"
        let mockCallbackUrl = URL(string: "https://test.com")!
        let expectedPresentationRequirement = VerifiedIdRequirement(encrypted: false,
                                                                    required: true,
                                                                    types: [],
                                                                    purpose: nil,
                                                                    issuanceOptions: [VerifiedIdRequestURL(url: issuanceOptionURL)],
                                                                    id: nil,
                                                                    constraint: GroupConstraint(constraints: [],
                                                                                                constraintOperator: .ALL))
        let expectedPresentationRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedPresentationContent = PresentationRequestContent(style: expectedPresentationStyle,
                                                                     requirement: expectedPresentationRequirement,
                                                                     rootOfTrust: expectedPresentationRootOfTrust,
                                                                     requestState: mockState,
                                                                     callbackUrl: mockCallbackUrl)
        
        let expectedIssuanceStyle = MockRequesterStyle(requester: "mock issuer")
        let expectedIssuanceRequirement = MockRequirement(id: "mockRequirement23535")
        let expectedIssuanceRootOfTrust = RootOfTrust(verified: true, source: "mock issuer source")
        let expectedIssuanceContent = IssuanceRequestContent(style: expectedIssuanceStyle,
                                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                                             requirement: expectedIssuanceRequirement,
                                                             rootOfTrust: expectedIssuanceRootOfTrust)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedPresentationContent
            }
            
            if objectToBeMapped is IssuanceRequest {
                return expectedIssuanceContent
            }
            
            return nil
        }
        
        func mockResolveContract(url: String) throws -> any RawManifest {
            return createMockIssuanceRequest()
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestProcessor(configuration: configuration,
                                           openIdResponder: MockPresentationResponder(),
                                           manifestResolver: MockManifestResolver(mockGetRequestCallback: mockResolveContract),
                                           verifiableCredentialRequester: MockVerifiedIdRequester())
        
        // Act
        let actualRequest = try await handler.process(rawRequest: mockRawRequest)
        
        // Assert
        XCTAssert(actualRequest is ContractIssuanceRequest)
        XCTAssertEqual(actualRequest.style as? MockRequesterStyle, expectedIssuanceStyle)
        XCTAssertEqual(actualRequest.requirement as? MockRequirement, expectedIssuanceRequirement)
        XCTAssertEqual(actualRequest.rootOfTrust.source, expectedIssuanceRootOfTrust.source)
        XCTAssertEqual((actualRequest as? ContractIssuanceRequest)?.requestState, mockState)
        XCTAssertEqual((actualRequest as? ContractIssuanceRequest)?.issuanceResultCallbackUrl, mockCallbackUrl)
        XCTAssert(actualRequest.rootOfTrust.verified)
    }
    
    func testProcessIssuanceRequest_WithValidContractAndIdTokenRequirement_ReturnsVerifiedIdIssuanceRequest() async throws {
        
        // Arrange
        let issuanceOptionURL = URL(string: "https://test.com")!
        let expectedPresentationStyle = MockRequesterStyle(requester: "mock requester")
        let mockState = "mock state"
        let mockCallbackUrl = URL(string: "https://test.com")!
        let expectedPresentationRequirement = VerifiedIdRequirement(encrypted: false,
                                                                    required: true,
                                                                    types: [],
                                                                    purpose: nil,
                                                                    issuanceOptions: [VerifiedIdRequestURL(url: issuanceOptionURL)],
                                                                    id: nil,
                                                                    constraint: GroupConstraint(constraints: [],
                                                                                                constraintOperator: .ALL))
        let expectedPresentationRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedPresentationContent = PresentationRequestContent(style: expectedPresentationStyle,
                                                                     requirement: expectedPresentationRequirement,
                                                                     rootOfTrust: expectedPresentationRootOfTrust,
                                                                     requestState: mockState,
                                                                     callbackUrl: mockCallbackUrl)
        
        let expectedIssuanceStyle = MockRequesterStyle(requester: "mock issuer")
        let expectedIssuanceRequirement = createIdTokenRequirement()
        let expectedIssuanceRootOfTrust = RootOfTrust(verified: true, source: "mock issuer source")
        let expectedIssuanceContent = IssuanceRequestContent(style: expectedIssuanceStyle,
                                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                                             requirement: expectedIssuanceRequirement,
                                                             rootOfTrust: expectedIssuanceRootOfTrust)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedPresentationContent
            }
            
            if objectToBeMapped is IssuanceRequest {
                return expectedIssuanceContent
            }
            
            return nil
        }
        
        func mockResolveContract(url: String) throws -> any RawManifest {
            return createMockIssuanceRequest()
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestProcessor(configuration: configuration,
                                           openIdResponder: MockPresentationResponder(),
                                           manifestResolver: MockManifestResolver(mockGetRequestCallback: mockResolveContract),
                                           verifiableCredentialRequester: MockVerifiedIdRequester())
        
        // Act
        let actualRequest = try await handler.process(rawRequest: mockRawRequest)
        
        // Assert
        XCTAssert(actualRequest is ContractIssuanceRequest)
        XCTAssertEqual(actualRequest.style as? MockRequesterStyle, expectedIssuanceStyle)
        XCTAssertNotNil((actualRequest.requirement as? IdTokenRequirement)?.nonce)
        XCTAssertEqual(actualRequest.rootOfTrust.source, expectedIssuanceRootOfTrust.source)
        XCTAssertEqual((actualRequest as? ContractIssuanceRequest)?.requestState, mockState)
        XCTAssertEqual((actualRequest as? ContractIssuanceRequest)?.issuanceResultCallbackUrl, mockCallbackUrl)
        XCTAssert(actualRequest.rootOfTrust.verified)
    }
    
    func testProcessIssuanceRequest_WithValidContractAndInjectedIdToken_ReturnsVerifiedIdIssuanceRequest() async throws {
        
        // Arrange
        let issuanceOptionURL = URL(string: "https://test.com")!
        let mockState = "mock state"
        let mockCallbackUrl = URL(string: "https://test.com")!
        let expectedPresentationStyle = MockRequesterStyle(requester: "mock requester")
        let expectedPresentationRequirement = VerifiedIdRequirement(encrypted: false,
                                                                    required: true,
                                                                    types: [],
                                                                    purpose: nil,
                                                                    issuanceOptions: [VerifiedIdRequestURL(url: issuanceOptionURL)],
                                                                    id: nil,
                                                                    constraint: GroupConstraint(constraints: [],
                                                                                                          constraintOperator: .ALL))
        let expectedPresentationRootOfTrust = RootOfTrust(verified: true, source: "mock source")
        let expectedInjectedIdToken = InjectedIdToken(rawToken: "mock idToken hint", pin: nil)
        let expectedPresentationContent = PresentationRequestContent(style: expectedPresentationStyle,
                                                                     requirement: expectedPresentationRequirement,
                                                                     rootOfTrust: expectedPresentationRootOfTrust,
                                                                     requestState: mockState,
                                                                     callbackUrl: mockCallbackUrl,
                                                                     injectedIdToken: expectedInjectedIdToken)
        
        let expectedIssuanceStyle = MockRequesterStyle(requester: "mock issuer")
        let expectedIssuanceRequirement = MockRequirement(id: "mockRequirement23535")
        let expectedIssuanceRootOfTrust = RootOfTrust(verified: true, source: "mock issuer source")
        let expectedIssuanceContent = IssuanceRequestContent(style: expectedIssuanceStyle,
                                                             verifiedIdStyle: MockVerifiedIdStyle(),
                                                             requirement: expectedIssuanceRequirement,
                                                             rootOfTrust: expectedIssuanceRootOfTrust)
        
        func mockResults(objectToBeMapped: Any) throws -> Any? {
            if objectToBeMapped is MockOpenIdRawRequest {
                return expectedPresentationContent
            }
            
            if objectToBeMapped is IssuanceRequest {
                return expectedIssuanceContent
            }
            
            return nil
        }
        
        func mockResolveContract(url: String) throws -> any RawManifest {
            return createMockIssuanceRequest()
        }
        
        let mockMapper = MockMapper(mockResults: mockResults)
        let mockRawRequest = MockOpenIdRawRequest(raw: Data(), type: .Issuance)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: mockMapper)
        let handler = OpenIdRequestProcessor(configuration: configuration,
                                           openIdResponder: MockPresentationResponder(),
                                           manifestResolver: MockManifestResolver(mockGetRequestCallback: mockResolveContract),
                                           verifiableCredentialRequester: MockVerifiedIdRequester())
        
        // Act
        let actualRequest = try await handler.process(rawRequest: mockRawRequest)
        
        // Assert
        XCTAssert(actualRequest is ContractIssuanceRequest)
        XCTAssertEqual(actualRequest.style as? MockRequesterStyle, expectedIssuanceStyle)
        XCTAssertEqual(actualRequest.requirement as? MockRequirement, expectedIssuanceRequirement)
        XCTAssertEqual(actualRequest.rootOfTrust.source, expectedIssuanceRootOfTrust.source)
        XCTAssertEqual((actualRequest as? ContractIssuanceRequest)?.requestState, mockState)
        XCTAssertEqual((actualRequest as? ContractIssuanceRequest)?.issuanceResultCallbackUrl, mockCallbackUrl)
        XCTAssert(actualRequest.rootOfTrust.verified)
    }
    
    private func createMockIssuanceRequest() -> IssuanceRequest {
        let mockCardDisplay = CardDisplayDescriptor(title: "mock title",
                                                    issuedBy: "mock issuer",
                                                    backgroundColor: "mock background color",
                                                    textColor: "mock text color",
                                                    logo: nil,
                                                    cardDescription: "mock description")
        let mockConsentDisplay = ConsentDisplayDescriptor(title: nil,
                                                          instructions: "mock purpose")
        let mockDisplayDescriptor = DisplayDescriptor(id: nil,
                                                      locale: nil,
                                                      contract: nil,
                                                      card: mockCardDisplay,
                                                      consent: mockConsentDisplay,
                                                      claims: [:])
        let mockContractInputDescriptor = ContractInputDescriptor(credentialIssuer: "mock credential issuer",
                                                                  issuer: "mock issuer",
                                                                  attestations: nil)
        let mockContract = Contract(id: "mockContract",
                                    display: mockDisplayDescriptor,
                                    input: mockContractInputDescriptor)

        let mockSignedContract = SignedContract(headers: Header(), content: mockContract)!
        return IssuanceRequest(from: mockSignedContract, linkedDomainResult: .linkedDomainMissing)
    }
    
    private func createIdTokenRequirement(configuration: String = "https://self-issued.me") -> IdTokenRequirement {
        return IdTokenRequirement(encrypted: false,
                                  required: false,
                                  configuration: URL(string: configuration)!,
                                  clientId: "mockClientId",
                                  redirectUri: "mockRedirectUri",
                                  scope: nil)
    }
}
