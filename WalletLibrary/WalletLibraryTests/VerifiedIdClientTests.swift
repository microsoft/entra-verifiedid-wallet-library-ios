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
    }
    
    func testCreateRequest_WhenResolverFactoryThrows_ThrowError() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: false)
        let resolverFactory = RequestResolverFactory(resolvers: [resolver])
        
        let mockInput = MockInput(mockData: "")
        
        let handlerFactory = RequestHandlerFactory(requestHandlers: [])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        do {
            let _ = try await client.createVerifiedIdRequest(from: mockInput)
            XCTFail("Should have thrown.")
        } catch {
            // Assert
            XCTAssert(error is RequestResolverFactoryError)
            XCTAssertEqual(error as? RequestResolverFactoryError, .UnsupportedInput)
        }
    }
    
    func testCreateRequest_WhenResolverThrows_ThrowError() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: true,
                                    canResolveUsingHandler: { _ in false },
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
            let _ = try await client.createVerifiedIdRequest(from: mockInput)
            XCTFail("Should have thrown.")
        } catch {
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, .expectedToBeThrownInResolver)
        }
    }
    
    func testCreateRequest_WhenHandlerFactoryThrows_ThrowError() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: true,
                                    canResolveUsingHandler: { _ in false },
                                    mockResolve: {_ in MockRawRequest(raw: "")})
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
            let _ = try await client.createVerifiedIdRequest(from: mockInput)
            XCTFail("Should have thrown.")
        } catch {
            // Assert
            XCTAssert(error is RequestHandlerFactoryError)
            XCTAssertEqual(error as? RequestHandlerFactoryError, .UnsupportedResolver)
        }
    }
    
    func testCreateRequest_WhenHandlerThrows_ThrowError() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: true,
                                    canResolveUsingHandler: { _ in true },
                                    mockResolve: {_ in MockRawRequest(raw: "")})
        let resolverFactory = RequestResolverFactory(resolvers: [resolver])
        
        let mockInput = MockInput(mockData: "")
        
        let mockHandler = MockHandler(mockHandleRequest: { throw ExpectedError.expectedToBeThrownInHandler })
        let handlerFactory = RequestHandlerFactory(requestHandlers: [mockHandler])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        do {
            let _ = try await client.createVerifiedIdRequest(from: mockInput)
            XCTFail("Should have thrown.")
        } catch {
            // Assert
            XCTAssert(error is ExpectedError)
            XCTAssertEqual(error as? ExpectedError, .expectedToBeThrownInHandler)
        }
    }
    
    func testCreateRequest_WithNoErrorsThrown_ReturnsVerifiedIdRequest() async throws {
        // Arrange
        let resolver = MockResolver(canResolveUsingInput: true,
                                    canResolveUsingHandler: { _ in true },
                                    mockResolve: {_ in MockRawRequest(raw: "")})
        let resolverFactory = RequestResolverFactory(resolvers: [resolver])
        
        let mockInput = MockInput(mockData: "")
        
        let expectedRequest = MockVerifiedIdRequest()
        
        let mockHandler = MockHandler(mockHandleRequest: { return expectedRequest })
        let handlerFactory = RequestHandlerFactory(requestHandlers: [mockHandler])
        let configuration = LibraryConfiguration(logger: WalletLibraryLogger(), mapper: Mapper())
        
        let client = VerifiedIdClient(requestResolverFactory: resolverFactory,
                                      requestHandlerFactory: handlerFactory,
                                      configuration: configuration)
        
        // Act
        let actualResult = try await client.createVerifiedIdRequest(from: mockInput)
        
        XCTAssertIdentical(actualResult as AnyObject, expectedRequest as AnyObject)
    }
}
