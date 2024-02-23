/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdClientBuilderTests: XCTestCase {

    func testBuild_WithNoLogConsumers_ReturnsVerifiedIdClient() throws {
        // Arrange
        let builder = VerifiedIdClientBuilder()
        
        // Act
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestHandler })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIHandler })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
        XCTAssertNil(builder.keychainAccessGroupIdentifier)
    }
    
    func testBuild_WithOneLogConsumer_ReturnsVerifiedIdClient() throws {
        // Arrange
        let mockLogConsumer = MockLogConsumer()
        let builder = VerifiedIdClientBuilder()
            .with(logConsumer: mockLogConsumer)
        
        // Act
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestHandler })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIHandler })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssertEqual(actualResult.configuration.logger.consumers.count, 1)
        XCTAssert(actualResult.configuration.logger.consumers.contains { $0 is MockLogConsumer })
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
        XCTAssertNil(builder.keychainAccessGroupIdentifier)
    }
    
    func testBuild_WithMultipleLogConsumers_ReturnsVerifiedIdClient() throws {
        // Arrange
        let firstLogConsumer = MockLogConsumer()
        let secondLogConsumer = MockLogConsumer()
        let thirdLogConsumer = MockLogConsumer()
        let builder = VerifiedIdClientBuilder()
            .with(logConsumer: firstLogConsumer)
            .with(logConsumer: secondLogConsumer)
            .with(logConsumer: thirdLogConsumer)
        
        // Act
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestHandler })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIHandler })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssertEqual(actualResult.configuration.logger.consumers.count, 3)
        XCTAssert(actualResult.configuration.logger.consumers.contains { $0 as? MockLogConsumer == firstLogConsumer })
        XCTAssert(actualResult.configuration.logger.consumers.contains { $0 as? MockLogConsumer == secondLogConsumer })
        XCTAssert(actualResult.configuration.logger.consumers.contains { $0 as? MockLogConsumer == thirdLogConsumer })
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
        XCTAssertNil(builder.keychainAccessGroupIdentifier)
    }
    
    func testWithKeyChainIdentifier_WithValueInjected_ReturnsVerifiedIdClient() throws {
        // Arrange
        let expectedKeychainAccessGroupIdentifier = "expected keychain access group identifier"
        
        // Act
        let builder = VerifiedIdClientBuilder()
            .with(keychainAccessGroupIdentifier: expectedKeychainAccessGroupIdentifier)
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestHandler })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIHandler })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
        XCTAssertEqual(builder.keychainAccessGroupIdentifier, expectedKeychainAccessGroupIdentifier)
    }
    
    func testBuild_WithCorrelationHeaderInjected_ReturnsVerifiedIdClient() throws {
        // Arrange
        let name = "expected header name"
        let value = "expected header value"
        let mockCorrelationHeader = MockCorrelationHeader(name: name, value: value)
        
        // Act
        let builder = VerifiedIdClientBuilder()
            .with(verifiedIdCorrelationHeader: mockCorrelationHeader)
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestHandler })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIHandler })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
        XCTAssert(actualResult.configuration.networking is WalletLibraryNetworking)
        XCTAssertEqual((actualResult.configuration.networking as! WalletLibraryNetworking).correlationHeader?.name,
                       name)
        XCTAssertEqual((actualResult.configuration.networking as! WalletLibraryNetworking).correlationHeader?.value,
                       value)
    }
    
    func testBuild_WithURLSessionInjected_ReturnsVerifiedIdClient() throws {
        // Arrange
        let expectedURLSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        // Act
        let builder = VerifiedIdClientBuilder()
            .with(urlSession: expectedURLSession)
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestHandler })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIHandler })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
        XCTAssert(actualResult.configuration.networking is WalletLibraryNetworking)
        XCTAssert((actualResult.configuration.networking as! WalletLibraryNetworking).urlSession === expectedURLSession)
    }
    
    func testBuild_WithPreviewFlagInjection_ReturnsVerifiedIdClient() throws {
        // Arrange
        let mockPreviewFeature = "mockPreviewFeature"
        let unsupportedPreviewFeature = "unsupportedPreviewFeature"
        
        // Act
        let builder = VerifiedIdClientBuilder()
            .with(previewFeatureFlags: [mockPreviewFeature])
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestHandler })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIHandler })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
        XCTAssert(actualResult.configuration.isPreviewFeatureFlagSupported(mockPreviewFeature))
        XCTAssertFalse(actualResult.configuration.isPreviewFeatureFlagSupported(unsupportedPreviewFeature))
    }
}
