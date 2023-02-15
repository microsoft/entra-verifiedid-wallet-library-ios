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
        let actualResult = try builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 1)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestHandler })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssert(actualResult.configuration.logger.consumers.isEmpty)
    }
    
    func testBuild_WithOneLogConsumer_ReturnsVerifiedIdClient() throws {
        // Arrange
        let mockLogConsumer = MockLogConsumer()
        let builder = VerifiedIdClientBuilder()
            .with(logConsumer: mockLogConsumer)
        
        // Act
        let actualResult = try builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 1)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestHandler })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssertEqual(actualResult.configuration.logger.consumers.count, 1)
        XCTAssert(actualResult.configuration.logger.consumers.contains { $0 is MockLogConsumer })
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
        let actualResult = try builder.build()
        
        // Assert
        XCTAssertEqual(actualResult.requestHandlerFactory.requestHandlers.count, 1)
        XCTAssert(actualResult.requestHandlerFactory.requestHandlers.contains { $0 is OpenIdRequestHandler })
        XCTAssertEqual(actualResult.requestResolverFactory.resolvers.count, 1)
        XCTAssert(actualResult.requestResolverFactory.resolvers.contains { $0 is OpenIdURLRequestResolver })
        XCTAssertEqual(actualResult.configuration.logger.consumers.count, 3)
        XCTAssert(actualResult.configuration.logger.consumers.contains { $0 as? MockLogConsumer == firstLogConsumer })
        XCTAssert(actualResult.configuration.logger.consumers.contains { $0 as? MockLogConsumer == secondLogConsumer })
        XCTAssert(actualResult.configuration.logger.consumers.contains { $0 as? MockLogConsumer == thirdLogConsumer })
    }
}
