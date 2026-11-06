/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
import CryptoKit
@testable import WalletLibrary

class VerifiedIdClientTests: XCTestCase {

    func testCreateRequest_ResolverPolicyTransitionsPreserveExistingClients() async throws {
        let session = try presentationSession(controller: "did:test:other")
        defer { session.invalidateAndCancel() }
        let hardened = presentationClient(session: session, disableHardening: false)
        await assertPresentationFailure(hardened, expected: "invalidSignature")

        let legacy = presentationClient(session: session, disableHardening: true)
        let legacyRequest = try await legacy.createRequest(from: presentationInput).get()
        XCTAssert(legacyRequest is OpenIdPresentationRequest)

        let hardenedAgain = presentationClient(session: session, disableHardening: false)
        await assertPresentationFailure(hardenedAgain, expected: "invalidSignature")
        await assertPresentationFailure(hardened, expected: "invalidSignature")
        let existingLegacyRequest = try await legacy.createRequest(from: presentationInput).get()
        XCTAssert(existingLegacyRequest is OpenIdPresentationRequest)
    }

    func testCreateRequest_MatchingControllerSucceedsWithBothPolicies() async throws {
        let session = try presentationSession(controller: "did:test:verifier")
        defer { session.invalidateAndCancel() }
        for disabled in [false, true] {
            let client = presentationClient(session: session, disableHardening: disabled)
            let request = try await client.createRequest(from: presentationInput).get()
            XCTAssert(request is OpenIdPresentationRequest)
        }
    }

    func testCreateRequest_AbsentControllerSucceedsWithBothPolicies() async throws {
        let session = try presentationSession(controller: nil)
        defer { session.invalidateAndCancel() }
        for disabled in [false, true] {
            let client = presentationClient(session: session, disableHardening: disabled)
            let request = try await client.createRequest(from: presentationInput).get()
            XCTAssert(request is OpenIdPresentationRequest)
        }
    }

    func testCreateRequest_AbsoluteKeyIdUsesHardenedMatchingOnly() async throws {
        let session = try presentationSession(controller: "did:test:verifier",
                                              keyId: "did:test:verifier#key")
        defer { session.invalidateAndCancel() }
        let hardened = presentationClient(session: session, disableHardening: false)
        let request = try await hardened.createRequest(from: presentationInput).get()
        XCTAssert(request is OpenIdPresentationRequest)
        await assertPresentationFailure(presentationClient(session: session, disableHardening: true),
                                        expected: "invalidSignature")
    }

    func testCreateRequest_WrongKeyIdFailsWithBothPolicies() async throws {
        let session = try presentationSession(controller: "did:test:verifier", keyId: "#other")
        defer { session.invalidateAndCancel() }
        for disabled in [false, true] {
            await assertPresentationFailure(presentationClient(session: session, disableHardening: disabled),
                                            expected: "invalidSignature")
        }
    }

    func testCreateRequest_InvalidSignatureFailsWithBothPolicies() async throws {
        let session = try presentationSession(controller: "did:test:verifier", invalidSignature: true)
        defer { session.invalidateAndCancel() }
        for disabled in [false, true] {
            await assertPresentationFailure(presentationClient(session: session, disableHardening: disabled),
                                            expected: "invalidSignature")
        }
    }

    func testCreateRequest_ExpiredPresentationFailsWithBothPolicies() async throws {
        let session = try presentationSession(controller: "did:test:verifier", expired: true)
        defer { session.invalidateAndCancel() }
        for disabled in [false, true] {
            await assertPresentationFailure(presentationClient(session: session, disableHardening: disabled),
                                            expected: "tokenExpired")
        }
    }

    func testCreateRequest_InvalidScopeFailsWithBothPolicies() async throws {
        let session = try presentationSession(controller: "did:test:verifier", scope: "invalid")
        defer { session.invalidateAndCancel() }
        for disabled in [false, true] {
            await assertPresentationFailure(presentationClient(session: session, disableHardening: disabled),
                                            expected: "invalidScopeValue")
        }
    }

    func testCreateRequest_MismatchedDocumentFailsWithBothPolicies() async throws {
        let session = try presentationSession(controller: "did:test:verifier", documentId: "did:test:other")
        defer { session.invalidateAndCancel() }
        for disabled in [false, true] {
            let client = presentationClient(session: session, disableHardening: disabled)
            switch await client.createRequest(from: presentationInput) {
            case .success:
                XCTFail("Legacy matching must not bypass document identity validation")
            case .failure(let error):
                XCTAssertEqual(error.message, "Resolved Identifier Document does not match the requested DID.")
            }
        }
    }

    private var presentationInput: VerifiedIdRequestURL {
        VerifiedIdRequestURL(url: URL(string: "openid-vc://?request_uri=https%3A%2F%2Fpresentation.example%2Frequest")!)
    }

    private func presentationClient(session: URLSession, disableHardening: Bool) -> VerifiedIdClient {
        VerifiedIdClientBuilder()
            .with(urlSession: session)
            .with(previewFeatureFlags: disableHardening ? [PreviewFeatureFlags.DisableResolverHardening] : [])
            .build()
    }

    private func assertPresentationFailure(_ client: VerifiedIdClient, expected: String,
                                           file: StaticString = #filePath, line: UInt = #line) async {
        switch await client.createRequest(from: presentationInput) {
        case .success:
            XCTFail("Expected presentation validation to fail", file: file, line: line)
        case .failure(let error):
            let underlying = (error as? UnspecifiedVerifiedIdError)?.error
            let validationError = underlying as? PresentationRequestValidatorError
            XCTAssertNotNil(validationError, "\(error)", file: file, line: line)
            XCTAssertEqual(validationError.map { String(describing: $0) }, expected, file: file, line: line)
        }
    }

    private func presentationSession(controller: String?, keyId: String = "#key",
                                     invalidSignature: Bool = false, expired: Bool = false,
                                     scope: String = "openid", documentId: String = "did:test:verifier") throws -> URLSession {
        let privateKey = P256.Signing.PrivateKey()
        let header: [String: Any] = ["alg": "ES256", "kid": "did:test:verifier#key"]
        let claims: [String: Any] = [
            "client_id": "did:test:verifier",
            "redirect_uri": "https://presentation.example/callback",
            "response_mode": "post",
            "response_type": "id_token",
            "state": "test-state",
            "nonce": "test-nonce",
            "scope": scope,
            "exp": Int(Date().timeIntervalSince1970) + (expired ? -600 : 600),
            "registration": ["client_name": "Test verifier"],
            "claims": ["vp_token": ["presentation_definition": [
                "id": "test-definition",
                "input_descriptors": [["id": "test-credential", "schema": [["uri": "TestCredential"]]]]
            ]]]
        ]
        let message = try JSONSerialization.data(withJSONObject: header).base64URLEncodedString()
            + "." + JSONSerialization.data(withJSONObject: claims).base64URLEncodedString()
        let signingKey = invalidSignature ? P256.Signing.PrivateKey() : privateKey
        let signature = try signingKey.signature(for: Data(message.utf8)).rawRepresentation
        let token = Data((message + "." + signature.base64URLEncodedString()).utf8)

        let rawKey = privateKey.publicKey.x963Representation
        var method: [String: Any] = [
            "id": keyId,
            "type": "JsonWebKey2020",
            "publicKeyJwk": [
                "kty": "EC", "crv": "P-256",
                "x": Data(rawKey[1..<33]).base64URLEncodedString(),
                "y": Data(rawKey[33..<65]).base64URLEncodedString()
            ]
        ]
        method["controller"] = controller
        let document = try JSONSerialization.data(withJSONObject: [
            "didDocument": ["id": documentId, "verificationMethod": [method], "authentication": []]
        ])
        PresentationPolicyURLProtocol.response = { request in
            if request.url?.host == "presentation.example" {
                return token
            }
            XCTAssertEqual(request.url?.lastPathComponent, "did:test:verifier")
            return document
        }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [PresentationPolicyURLProtocol.self]
        return URLSession(configuration: configuration)
    }
    
    enum ExpectedError: Error {
        case expectedToBeThrownInResolver
        case expectedToBeThrownInHandler
        case expectedToBeThrownInDecoder
        case expectedToBeThrownInEncoder
    }

    private final class PresentationPolicyURLProtocol: URLProtocol {
        static var response: ((URLRequest) -> Data)?

        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            guard let data = Self.response?(request),
                  let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil,
                                                  headerFields: nil) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
                return
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
    
    func testCreateRequest_WhenResolverFactoryThrows_ThrowError() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: false)
        let resolverFactory = RequestResolverFactory(resolvers: [resolver])
        
        let mockInput = MockInput(mockData: "")
        
        let handlerFactory = RequestProcessorFactory(requestHandlers: [])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper())
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        do {
            let _ = try await client.createRequest(from: mockInput).get()
            XCTFail("Should have thrown.")
        } catch {
            // Assert
            XCTAssert(error is UnspecifiedVerifiedIdError)
            XCTAssertEqual((error as? UnspecifiedVerifiedIdError)?.code,
                           VerifiedIdErrors.ErrorCode.UnspecifiedError)
            let innerError = (error as! UnspecifiedVerifiedIdError).error
            XCTAssert(innerError is RequestResolverFactoryError)
            XCTAssertEqual(innerError as? RequestResolverFactoryError, .UnsupportedInput)
        }
    }
    
    func testCreateRequest_WhenResolverThrows_ThrowError() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: true,
                                    mockResolve: { _ in throw ExpectedError.expectedToBeThrownInResolver })
        let resolverFactory = RequestResolverFactory(resolvers: [resolver])
        
        let mockInput = MockInput(mockData: "")
        
        let mockHandler = MockHandler()
        let handlerFactory = RequestProcessorFactory(requestHandlers: [mockHandler])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        do {
            let _ = try await client.createRequest(from: mockInput).get()
            XCTFail("Should have thrown.")
        } catch {
            // Assert
            XCTAssert(error is UnspecifiedVerifiedIdError)
            XCTAssertEqual((error as? UnspecifiedVerifiedIdError)?.code,
                           VerifiedIdErrors.ErrorCode.UnspecifiedError)
            let innerError = (error as! UnspecifiedVerifiedIdError).error
            XCTAssert(innerError is ExpectedError)
            XCTAssertEqual(innerError as? ExpectedError, .expectedToBeThrownInResolver)
        }
    }
    
    func testCreateRequest_WhenHandlerFactoryThrows_ThrowError() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: true,
                                    mockResolve: {_ in MockRawRequest(raw: "")})
        let resolverFactory = RequestResolverFactory(resolvers: [resolver])
        
        let mockInput = MockInput(mockData: "")
        
        let mockHandler = MockHandler(mockCanHandle: false)
        let handlerFactory = RequestProcessorFactory(requestHandlers: [mockHandler])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        do {
            let _ = try await client.createRequest(from: mockInput).get()
            XCTFail("Should have thrown.")
        } catch {
            // Assert
            XCTAssert(error is VerifiedIdError)
            XCTAssertEqual((error as? VerifiedIdError)?.code, "unsupported_raw_request")
            XCTAssertEqual((error as? VerifiedIdError)?.message, "Unsupported Raw Request")
        }
    }
    
    func testCreateRequest_WhenHandlerThrows_ThrowError() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: true,
                                    mockResolve: {_ in MockRawRequest(raw: "")})
        let resolverFactory = RequestResolverFactory(resolvers: [resolver])
        
        let mockInput = MockInput(mockData: "")
        
        let mockHandler = MockHandler(mockCanHandle: true,
                                      mockHandleRequest: { throw ExpectedError.expectedToBeThrownInHandler })
        let handlerFactory = RequestProcessorFactory(requestHandlers: [mockHandler])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        do {
            let _ = try await client.createRequest(from: mockInput).get()
            XCTFail("Should have thrown.")
        } catch {
            // Assert
            XCTAssert(error is UnspecifiedVerifiedIdError)
            XCTAssertEqual((error as? UnspecifiedVerifiedIdError)?.code,
                           VerifiedIdErrors.ErrorCode.UnspecifiedError)
            let innerError = (error as! UnspecifiedVerifiedIdError).error
            XCTAssert(innerError is ExpectedError)
            XCTAssertEqual(innerError as? ExpectedError, .expectedToBeThrownInHandler)
        }
    }
    
    func testCreateRequest_WithNoErrorsThrown_ReturnsVerifiedIdRequest() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: true,
                                    mockResolve: {_ in MockRawRequest(raw: "")})
        let resolverFactory = RequestResolverFactory(resolvers: [resolver])
        
        let mockInput = MockInput(mockData: "")
        
        let expectedRequest = MockVerifiedIdRequest()
        
        let mockHandler = MockHandler(mockCanHandle: true,
                                      mockHandleRequest: { return expectedRequest })
        let handlerFactory = RequestProcessorFactory(requestHandlers: [mockHandler])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        let actualResult = try await client.createRequest(from: mockInput).get()
        
        XCTAssertIdentical(actualResult as AnyObject, expectedRequest as AnyObject)
    }
    
    func testCreateRequest_WithCorrelationHeader_ResetsCorrelationHeader() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: true,
                                    mockResolve: {_ in MockRawRequest(raw: "")})
        let resolverFactory = RequestResolverFactory(resolvers: [resolver])
        
        let mockInput = MockInput(mockData: "")
        
        let expectedRequest = MockVerifiedIdRequest()
        
        let mockHandler = MockHandler(mockCanHandle: true,
                                      mockHandleRequest: { return expectedRequest })
        let handlerFactory = RequestProcessorFactory(requestHandlers: [mockHandler])
        let mockCorrelationHeader = MockCorrelationHeader()
        let walletLibraryNetworking = WalletLibraryNetworking(urlSession: URLSession.shared,
                                                              logger: WalletLibraryLogger(),
                                                              correlationHeader: mockCorrelationHeader)
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(), 
                                                 networking: walletLibraryNetworking)
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        let actualResult = try await client.createRequest(from: mockInput).get()
        
        // Assert
        XCTAssert(mockCorrelationHeader.wasResetCalled)
        XCTAssertIdentical(actualResult as AnyObject, expectedRequest as AnyObject)
    }
    
    func testEncode_WithEncoderErrorThrown_ThrowsError() async throws {
        // Arrange
        let resolverFactory = RequestResolverFactory(resolvers: [])
        let handlerFactory = RequestProcessorFactory(requestHandlers: [])
        let mockVerifiedId = MockVerifiedId(id: "mock", issuedOn: Date())
        
        func mockEncode(verifiedId: VerifiedId) throws -> Data {
            throw ExpectedError.expectedToBeThrownInEncoder
        }
        
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(),
                                                 verifiedIdEncoder: MockVerifiedIdEncoder(mockEncode: mockEncode))
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        XCTAssertThrowsError(try client.encode(verifiedId: mockVerifiedId).get()) { error in
            // Assert
            XCTAssert(error is MalformedInputError)
            XCTAssertEqual((error as? MalformedInputError)?.code,
                           VerifiedIdErrors.ErrorCode.MalformedInputError)
            let innerError = (error as! MalformedInputError).error
            XCTAssert(innerError is ExpectedError)
            XCTAssertEqual(innerError as? ExpectedError, .expectedToBeThrownInEncoder)
        }
    }
    
    func testEncode_WithNoErrorsThrown_ReturnsData() async throws {
        // Arrange
        let resolverFactory = RequestResolverFactory(resolvers: [])
        let handlerFactory = RequestProcessorFactory(requestHandlers: [])
        let mockVerifiedId = MockVerifiedId(id: "mock", issuedOn: Date())
        let expectedEncodingResult = "mock encoding result".data(using: .utf8)!
        
        func mockEncode(verifiedId: VerifiedId) throws -> Data {
            return expectedEncodingResult
        }
        
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(),
                                                 verifiedIdEncoder: MockVerifiedIdEncoder(mockEncode: mockEncode))
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        let result = try client.encode(verifiedId: mockVerifiedId).get()
        
        // Assert
        XCTAssertEqual(result, expectedEncodingResult)
    }
    
    func testDecode_WithDecoderErrorThrown_ThrowsError() async throws {
        // Arrange
        let resolverFactory = RequestResolverFactory(resolvers: [])
        let handlerFactory = RequestProcessorFactory(requestHandlers: [])
        let mockData = "mockInputData".data(using: .utf8)!
        
        func mockDecode(data: Data) throws -> VerifiedId {
            throw ExpectedError.expectedToBeThrownInDecoder
        }
        
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(),
                                                 verifiedIdDecoder: MockVerifiedIdDecoder(mockDecode: mockDecode))
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        XCTAssertThrowsError(try client.decodeVerifiedId(from: mockData).get()) { error in
            // Assert
            XCTAssert(error is MalformedInputError)
            XCTAssertEqual((error as? MalformedInputError)?.code,
                           VerifiedIdErrors.ErrorCode.MalformedInputError)
            let innerError = (error as! MalformedInputError).error
            XCTAssert(innerError is ExpectedError)
            XCTAssertEqual(innerError as? ExpectedError, .expectedToBeThrownInDecoder)
        }
    }
    
    func testDecode_WithNoErrorsThrown_ReturnsVerifiedId() async throws {
        // Arrange
        let resolverFactory = RequestResolverFactory(resolvers: [])
        let handlerFactory = RequestProcessorFactory(requestHandlers: [])
        let expectedVerifiedId = MockVerifiedId(id: "mock", issuedOn: Date())
        let mockData = "mock encoding result".data(using: .utf8)!
        
        func mockDecode(data: Data) throws -> VerifiedId {
            return expectedVerifiedId
        }
        
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(),
                                                 verifiedIdDecoder: MockVerifiedIdDecoder(mockDecode: mockDecode))
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        let result = try client.decodeVerifiedId(from: mockData).get()
        
        // Assert
        XCTAssertEqual(result as? MockVerifiedId, expectedVerifiedId)
    }
}
