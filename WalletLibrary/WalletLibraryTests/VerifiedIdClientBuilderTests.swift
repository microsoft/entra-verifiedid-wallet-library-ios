/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class VerifiedIdClientKeyRecoveryTests: XCTestCase
{
    enum LoadingError: Error
    {
        case fips
        case legacy
    }

    private var originalConfiguration = VCSDKConfiguration.sharedInstance
    private var originalLog = VCSDKLog.sharedInstance
    private let fipsHolder = MockHolderIdentifier(id: "fips-test-holder", algorithm: "ES256", method: "did:jwk")

    override func setUp()
    {
        super.setUp()
        originalConfiguration = VCSDKConfiguration.sharedInstance
        originalLog = VCSDKLog.sharedInstance
    }

    override func tearDown()
    {
        VCSDKConfiguration.sharedInstance = originalConfiguration
        VCSDKLog.sharedInstance = originalLog
        super.tearDown()
    }

    func testDefaultRepositoryIsCreatedWithFinalGroupAndFreshSnapshot() throws
    {
        VCSDKConfiguration.sharedInstance.setAccessGroupIdentifier(with: "old-group")
        let builder = VerifiedIdClientBuilder()
        var snapshots: [Random32BytesSecret] = []
        builder.identifierRepositoryFactory = { _ in
            let key = KeyManagementOperations().retrieveKeyFromStorage(withId: UUID())
            if let secret = key as? Random32BytesSecret {
                snapshots.append(secret)
            } else {
                XCTFail("Expected the default key operations to create a stored 32-byte secret")
            }
            return MockIdentifierRepository(expectedIdentifier: self.fipsHolder)
        }
        XCTAssertTrue(snapshots.isEmpty)
        _ = builder.with(keychainAccessGroupIdentifier: "final-group")
            .with(previewFeatureFlags: [PreviewFeatureFlags.FIPSCompliantIdentifier])
            .build()
        _ = builder.with(keychainAccessGroupIdentifier: nil).build()

        XCTAssertEqual(snapshots.count, 2)
        XCTAssertEqual(try XCTUnwrap(snapshots.first).accessGroup, "final-group")
        XCTAssertNil(try XCTUnwrap(snapshots.last).accessGroup)
        XCTAssertNil(VCSDKConfiguration.sharedInstance.accessGroupIdentifier)
    }

    func testInjectedRepositorySelectsFIPSWithoutLoadingLegacy() throws
    {
        let builder = VerifiedIdClientBuilder(identifierRepository:
            MockIdentifierRepository(expectedIdentifier: fipsHolder))
        builder.identifierRepositoryFactory = { _ in
            XCTFail("Must preserve injected repository")
            return MockIdentifierRepository()
        }
        builder.legacyHolderIdentifierLoader = {
            XCTFail("Successful FIPS selection must not load legacy")
            throw LoadingError.legacy
        }
        let client = builder.with(previewFeatureFlags: [PreviewFeatureFlags.FIPSCompliantIdentifier])
            .with(identifier: MockHolderIdentifier()).build()

        XCTAssertTrue(try client.isDefaultHolderIdentifierFIPSCompliant)
        XCTAssertEqual(try client.configuration.identifierFactory.getIdentifier() as? MockHolderIdentifier,
                       fipsHolder)
    }

    func testFlagAloneDoesNotReportFIPSForWrongMethodOrAlgorithm()
    {
        for holder in [MockHolderIdentifier(algorithm: "ES256K", method: "did:jwk"),
                       MockHolderIdentifier(algorithm: "ES256", method: "did:ion")]
        {
            let client = VerifiedIdClientBuilder(identifierRepository:
                MockIdentifierRepository(expectedIdentifier: holder))
                .with(previewFeatureFlags: [PreviewFeatureFlags.FIPSCompliantIdentifier]).build()
            XCTAssertFalse(try client.isDefaultHolderIdentifierFIPSCompliant)
        }
    }

    func testFIPSFailureRetainsLegacyFallback() throws
    {
        let legacy = MockHolderIdentifier()
        let builder = VerifiedIdClientBuilder(identifierRepository:
            MockIdentifierRepository(expectedErrorThrown: LoadingError.fips))
        builder.legacyHolderIdentifierLoader = { legacy }
        let client = builder.with(previewFeatureFlags: [PreviewFeatureFlags.FIPSCompliantIdentifier]).build()

        XCTAssertFalse(try client.isDefaultHolderIdentifierFIPSCompliant)
        XCTAssertEqual(try client.configuration.identifierFactory.getIdentifier() as? MockHolderIdentifier, legacy)
    }

    func testBothFailuresPreservePrimaryFIPSError()
    {
        let builder = VerifiedIdClientBuilder(identifierRepository:
            MockIdentifierRepository(expectedErrorThrown: LoadingError.fips))
        builder.legacyHolderIdentifierLoader = { throw LoadingError.legacy }
        let client = builder.with(previewFeatureFlags: [PreviewFeatureFlags.FIPSCompliantIdentifier]).build()

        XCTAssertThrowsError(try client.isDefaultHolderIdentifierFIPSCompliant) {
            XCTAssertEqual($0 as? LoadingError, .fips)
        }
        XCTAssertThrowsError(try client.configuration.identifierFactory.getIdentifier()) {
            XCTAssertEqual($0 as? LoadingError, .fips)
        }
    }

    func testLegacyFailureIsPreservedWithoutFIPS()
    {
        let builder = VerifiedIdClientBuilder()
        builder.legacyHolderIdentifierLoader = { throw LoadingError.legacy }
        let client = builder.build()

        XCTAssertThrowsError(try client.isDefaultHolderIdentifierFIPSCompliant) {
            XCTAssertEqual($0 as? LoadingError, .legacy)
        }
        XCTAssertThrowsError(try client.configuration.identifierFactory.getIdentifier()) {
            XCTAssertEqual($0 as? LoadingError, .legacy)
        }
    }

    func testInjectedHolderRemainsUsableWhenBuiltInLoadingFails() throws
    {
        let builder = VerifiedIdClientBuilder(identifierRepository:
            MockIdentifierRepository(expectedErrorThrown: LoadingError.fips))
        builder.legacyHolderIdentifierLoader = { throw LoadingError.legacy }
        let client = builder.with(identifier: fipsHolder)
            .with(previewFeatureFlags: [PreviewFeatureFlags.FIPSCompliantIdentifier]).build()

        XCTAssertFalse(try client.isDefaultHolderIdentifierFIPSCompliant)
        XCTAssertEqual(try client.configuration.identifierFactory.getIdentifier() as? MockHolderIdentifier,
                       fipsHolder)
    }

    func testRepeatedBuildDoesNotRetainPreviousHolderOrRequestDependencies()
    {
        let builder = VerifiedIdClientBuilder()
        builder.legacyHolderIdentifierLoader = { self.fipsHolder }
        let first = builder.build()
        builder.legacyHolderIdentifierLoader = { throw LoadingError.legacy }
        let second = builder.build()

        XCTAssertEqual(first.configuration.identifierFactory.identifiers.count, 1)
        XCTAssertTrue(second.configuration.identifierFactory.identifiers.isEmpty)
        XCTAssertEqual(second.requestResolverFactory.resolvers.count, 1)
        XCTAssertEqual(second.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssertThrowsError(try second.configuration.identifierFactory.getIdentifier()) {
            XCTAssertEqual($0 as? LoadingError, .legacy)
        }
    }
}

class VerifiedIdClientBuilderTests: XCTestCase {

    func testBuild_WithNoLogConsumers_ReturnsVerifiedIdClient() throws {
        // Arrange
        let builder = VerifiedIdClientBuilder()
        
        // Act
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
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
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
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
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
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
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
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
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
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
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
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
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
        XCTAssert(actualResult.configuration.isPreviewFeatureFlagSupported(mockPreviewFeature))
        XCTAssertFalse(actualResult.configuration.isPreviewFeatureFlagSupported(unsupportedPreviewFeature))
    }

    func testBuild_WithoutDisableResolverHardeningFlag_KeepsResolverHardeningEnabled() throws {
        // Act
        let actualResult = VerifiedIdClientBuilder().build()

        // Assert
        XCTAssertFalse(actualResult.configuration.isPreviewFeatureFlagSupported(
            PreviewFeatureFlags.DisableResolverHardening))
    }

    func testBuild_WithDisableResolverHardeningFlag_DisablesResolverHardening() throws {
        // Act
        let actualResult = VerifiedIdClientBuilder()
            .with(previewFeatureFlags: [PreviewFeatureFlags.DisableResolverHardening])
            .build()

        // Assert
        XCTAssert(actualResult.configuration.isPreviewFeatureFlagSupported(
            PreviewFeatureFlags.DisableResolverHardening))
    }
    
    func testBuild_WithVerifiedIdExtensionInjection_ReturnsVerifiedIdClient() throws {
        // Arrange
        let expectedHeaders = ["headerValue1", "headerValue2"]
        let expectedProcessor = MockRequestProcessorExtension<OpenIdRequestProcessor>()
        let mockProcessorExtension = MockVerifiedIdExtension(prefer: expectedHeaders,
                                                             processors: [expectedProcessor])
        
        // Act
        let builder = VerifiedIdClientBuilder()
            .with(verifiedIdExtension: mockProcessorExtension)
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
        
        // Assert Processor Injection
        let openIdRequestProcessor = actualResult.requestHandlerFactory.requestHandlers.first { $0 is OpenIdRequestProcessor }
        let processorResults = openIdRequestProcessor?.requestProcessorExtensions as? [MockRequestProcessorExtension<OpenIdRequestProcessor>]
        XCTAssertEqual(openIdRequestProcessor?.requestProcessorExtensions.count, 1)
        XCTAssertEqual(processorResults?.first?.id, expectedProcessor.id)
        
        // Assert Prefer Header Injection
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.first?.preferHeaders, expectedHeaders)
        
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
    }
    
    func testBuild_With3ProcessorExtensionInjection_ReturnsVerifiedIdClient() throws {
        // Arrange
        let expectedHeaders = ["headerValue1", "headerValue2"]
        let expectedProcessor1 = MockRequestProcessorExtension<OpenIdRequestProcessor>()
        let expectedProcessor2 = MockRequestProcessorExtension<OpenIdRequestProcessor>()
        let expectedProcessor3 = MockRequestProcessorExtension<OpenIdRequestProcessor>()
        let processors = [expectedProcessor1, expectedProcessor2, expectedProcessor3]
        let mockProcessorExtension = MockVerifiedIdExtension(prefer: expectedHeaders,
                                                             processors: processors)
        
        // Act
        let builder = VerifiedIdClientBuilder()
            .with(verifiedIdExtension: mockProcessorExtension)
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
        
        // Assert Processor Injection
        let openIdRequestProcessor = actualResult.requestHandlerFactory.requestHandlers.first { $0 is OpenIdRequestProcessor }
        let processorResults = openIdRequestProcessor?.requestProcessorExtensions as? [MockRequestProcessorExtension<OpenIdRequestProcessor>]
        XCTAssertEqual(openIdRequestProcessor?.requestProcessorExtensions.count, 3)
        XCTAssertEqual(processorResults?[0].id, expectedProcessor1.id)
        XCTAssertEqual(processorResults?[1].id, expectedProcessor2.id)
        XCTAssertEqual(processorResults?[2].id, expectedProcessor3.id)
        
        // Assert Prefer Header Injection
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.first?.preferHeaders, expectedHeaders)
        
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
    }
    
    func testBuild_WithProcessorExtensionNotInjected_ReturnsVerifiedIdClient() throws {
        // Arrange
        let expectedHeaders = ["headerValue1", "headerValue2"]
        let expectedProcessor = MockRequestProcessorExtension<OpenIdRequestProcessor>()
        let processorToNotBeInjected = MockRequestProcessorExtension<MockHandler>()
        let mockProcessorExtension = MockVerifiedIdExtension(prefer: expectedHeaders,
                                                             processors: [expectedProcessor,
                                                                          processorToNotBeInjected])
        
        // Act
        let builder = VerifiedIdClientBuilder()
            .with(verifiedIdExtension: mockProcessorExtension)
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
        
        // Assert Processor Injection
        let openIdRequestProcessor = actualResult.requestHandlerFactory.requestHandlers.first { $0 is OpenIdRequestProcessor }
        let processorResults = openIdRequestProcessor?.requestProcessorExtensions as? [MockRequestProcessorExtension<OpenIdRequestProcessor>]
        XCTAssertEqual(openIdRequestProcessor?.requestProcessorExtensions.count, 1)
        XCTAssertEqual(processorResults?.first?.id, expectedProcessor.id)
        
        // Assert Prefer Header Injection
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.first?.preferHeaders, expectedHeaders)
        
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
    }
    
    func testBuild_With3VerifiedIdExtensionInjection_ReturnsVerifiedIdClient() throws {
        // Arrange
        let expectedHeaders = ["headerValue1", "headerValue2"]
        let expectedProcessor1 = MockRequestProcessorExtension<OpenIdRequestProcessor>()
        let expectedProcessor2 = MockRequestProcessorExtension<OpenIdRequestProcessor>()
        let expectedProcessor3 = MockRequestProcessorExtension<OpenIdRequestProcessor>()
        let mockProcessorExtension1 = MockVerifiedIdExtension(prefer: expectedHeaders,
                                                             processors: [expectedProcessor1])
        let mockProcessorExtension2 = MockVerifiedIdExtension(prefer: [],
                                                             processors: [expectedProcessor2])
        let mockProcessorExtension3 = MockVerifiedIdExtension(prefer: [],
                                                             processors: [expectedProcessor3])
        
        // Act
        let builder = VerifiedIdClientBuilder()
            .with(verifiedIdExtension: mockProcessorExtension1)
            .with(verifiedIdExtension: mockProcessorExtension2)
            .with(verifiedIdExtension: mockProcessorExtension3)
        let actualResult = builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
        
        // Assert Processor Injection
        let openIdRequestProcessor = actualResult.requestHandlerFactory.requestHandlers.first { $0 is OpenIdRequestProcessor }
        let processorResults = openIdRequestProcessor?.requestProcessorExtensions as? [MockRequestProcessorExtension<OpenIdRequestProcessor>]
        XCTAssertEqual(openIdRequestProcessor?.requestProcessorExtensions.count, 3)
        XCTAssertEqual(processorResults?[0].id, expectedProcessor1.id)
        XCTAssertEqual(processorResults?[1].id, expectedProcessor2.id)
        XCTAssertEqual(processorResults?[2].id, expectedProcessor3.id)
        
        // Assert Prefer Header Injection
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.first?.preferHeaders, expectedHeaders)
        
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
    }
    
    func testBuild_WithIdentifierHolderInjection_ReturnsVerifiedIdClient() throws 
    {
        // Arrange
        let builder = VerifiedIdClientBuilder()
        let _ = VerifiableCredentialSDK.initialize()
        let mockHolder1 = MockHolderIdentifier(id: "mock1")
        let mockHolder2 = MockHolderIdentifier(id: "mock2")
        
        // Act
        let actualResult = builder
            .with(identifier: mockHolder1)
            .with(identifier: mockHolder2)
            .build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
        XCTAssertEqual(actualResult.configuration.identifierFactory.identifiers[0] as? MockHolderIdentifier, mockHolder1)
        XCTAssertEqual(actualResult.configuration.identifierFactory.identifiers[1] as? MockHolderIdentifier, mockHolder2)
    }
    
    func testBuild_WithFIPSCompliantPreviewFeatureFlag_ReturnsVerifiedIdClient() throws
    {
        // Arrange
        let mockHolderIdentifier = MockHolderIdentifier(id: "mockHolder1")
        let mockRepository = MockIdentifierRepository(expectedIdentifier: mockHolderIdentifier)
        let builder = VerifiedIdClientBuilder(identifierRepository: mockRepository)
        
        // Act
        let actualResult = builder
            .with(previewFeatureFlags: [PreviewFeatureFlags.FIPSCompliantIdentifier])
            .build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 2)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestProcessor })
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenId4VCIProcessor })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
        XCTAssert(actualResult.configuration.verifiedIdDecoder is VerifiedIdDecoder)
        XCTAssert(actualResult.configuration.verifiedIdEncoder is VerifiedIdEncoder)
        XCTAssertEqual(actualResult.configuration.identifierFactory.identifiers.count, 1)
        XCTAssertEqual(actualResult.configuration.identifierFactory.identifiers[0] as? MockHolderIdentifier,
                       mockHolderIdentifier)
    }
}
