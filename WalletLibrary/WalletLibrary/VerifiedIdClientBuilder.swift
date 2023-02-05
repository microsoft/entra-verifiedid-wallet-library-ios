/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The VerifiedIdClientBuilder configures VerifiedIdClient with any additional options.
 */
public class VerifiedIdClientBuilder {
    
    var logger: WalletLibraryLogger = WalletLibraryLogger()
    
    var requestFactory: RequestHandlerFactory = RequestHandlerFactory()

    public init() { }

    /// Builds the VerifiedIdClient with the set configuration from the builder.
    public func build() -> VerifiedIdClient {
        let configuration = ClientConfiguration(logger: logger)
        registerSupportedRequestHandlers(with: configuration)
        registerSupportedMappingStrategies()
        return VerifiedIdClient(configuration: configuration, requestFactory: requestFactory)
    }

    /// Optional method to add a custom log consumer to VerifiedIdClient.
    public func with(logConsumer: WalletLibraryLogConsumer) -> VerifiedIdClientBuilder {
        logger.add(consumer: logConsumer)
        return self
    }
    
    func with(requestHandler: RequestHandler) -> VerifiedIdClientBuilder {
        requestFactory.requestHandlers.append(requestHandler)
        return self
    }
    
    func with(inputMappingStrategy: any RequestResolver) -> VerifiedIdClientBuilder {
        requestFactory.mappingStrategies.append(inputMappingStrategy)
        return self
    }
    
    private func registerSupportedRequestHandlers(with configuration: VerifiedIdClientConfiguration) {
        let openIdRequestHandler = OpenIdRequestHandler(configuration: configuration)
        requestFactory.requestHandlers.append(openIdRequestHandler)
    }
    
    private func registerSupportedMappingStrategies() {
        let urlToOpenIdMapping = OpenIdURLRequestResolver()
        requestFactory.mappingStrategies.append(urlToOpenIdMapping)
    }
}

class ClientConfiguration: VerifiedIdClientConfiguration {
    let logger: WalletLibraryLogger
    
    init(logger: WalletLibraryLogger) {
        self.logger = logger
    }
}
