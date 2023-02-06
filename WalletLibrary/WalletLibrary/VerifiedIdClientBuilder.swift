/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCServices

/**
 * The VerifiedIdClientBuilder configures VerifiedIdClient with any additional options.
 */
public class VerifiedIdClientBuilder {
    
    var logger: WalletLibraryLogger = WalletLibraryLogger()
    
    var accessGroupIdentifier: String? = nil
    
    var requestHandlerFactory: RequestHandlerFactory = RequestHandlerFactory()
    
    var requestResolverFactory: RequestResolverFactory = RequestResolverFactory()

    public init() {}

    /// Builds the VerifiedIdClient with the set configuration from the builder.
    public func build() throws -> VerifiedIdClient {
        let _ = VerifiableCredentialSDK.initialize(accessGroupIdentifier: accessGroupIdentifier)
        let configuration = ClientConfiguration(logger: logger)
        registerSupportedRequestHandlers(with: configuration)
        registerRequestResolvers()
        return VerifiedIdClient(configuration: configuration,
                                resolverFactory: requestResolverFactory,
                                requestHandlerFactory: requestHandlerFactory)
    }
    
    /// Optional method to add a custom log consumer to VerifiedIdClient.
    public func with(logConsumer: WalletLibraryLogConsumer) -> VerifiedIdClientBuilder {
        logger.add(consumer: logConsumer)
        return self
    }
    
    public func with(accessGroupIdentifier: String) -> VerifiedIdClientBuilder {
        self.accessGroupIdentifier = accessGroupIdentifier
        return self
    }
    
    func with(requestHandler: RequestHandler) -> VerifiedIdClientBuilder {
        requestHandlerFactory.requestHandlers.append(requestHandler)
        return self
    }
    
    func with(requestResolver: any RequestResolver) -> VerifiedIdClientBuilder {
        requestResolverFactory.resolvers.append(requestResolver)
        return self
    }
    
    private func registerSupportedRequestHandlers(with configuration: VerifiedIdClientConfiguration) {
        let openIdRequestHandler = OpenIdRequestHandler(configuration: configuration)
        requestHandlerFactory.requestHandlers.append(openIdRequestHandler)
    }
    
    private func registerRequestResolvers() {
        let requestResolver = OpenIdURLRequestResolver(presentationService: PresentationService())
        requestResolverFactory.resolvers.append(requestResolver)
    }
}

class ClientConfiguration: VerifiedIdClientConfiguration {
    let logger: WalletLibraryLogger
    
    init(logger: WalletLibraryLogger) {
        self.logger = logger
    }
}
