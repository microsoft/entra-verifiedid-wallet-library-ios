/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdClientTests: XCTestCase {
    
    enum ExpectedError: Error {
        case expectedToBeThrownInResolver
        case expectedToBeThrownInHandler
        case expectedToBeThrownInDecoder
        case expectedToBeThrownInEncoder
    }
    
    func testCreateRequest_WhenResolverFactoryThrows_ThrowError() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: false)
        let resolverFactory = RequestResolverFactory(resolvers: [resolver])
        
        let mockInput = MockInput(mockData: "")
        
        let handlerFactory = RequestHandlerFactory(requestHandlers: [])
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
        let handlerFactory = RequestHandlerFactory(requestHandlers: [mockHandler])
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
        let handlerFactory = RequestHandlerFactory(requestHandlers: [mockHandler])
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
            XCTAssert(innerError is RequestHandlerFactoryError)
            XCTAssertEqual(innerError as? RequestHandlerFactoryError, .UnsupportedRawRequest)
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
        let handlerFactory = RequestHandlerFactory(requestHandlers: [mockHandler])
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
        let handlerFactory = RequestHandlerFactory(requestHandlers: [mockHandler])
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
        let handlerFactory = RequestHandlerFactory(requestHandlers: [mockHandler])
        let mockCorrelationHeader = MockCorrelationHeader()
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(),
                                                 mapper: Mapper(),
                                                 correlationHeader: mockCorrelationHeader)
        
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
        let handlerFactory = RequestHandlerFactory(requestHandlers: [])
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
        let handlerFactory = RequestHandlerFactory(requestHandlers: [])
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
        let handlerFactory = RequestHandlerFactory(requestHandlers: [])
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
        let handlerFactory = RequestHandlerFactory(requestHandlers: [])
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
