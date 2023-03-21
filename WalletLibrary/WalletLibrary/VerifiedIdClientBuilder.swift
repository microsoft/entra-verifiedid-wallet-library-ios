/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCServices

/**
 * The VerifiedIdClientBuilder configures VerifiedIdClient with any additional options.
 */
public class VerifiedIdClientBuilder {
    
    private var logger: WalletLibraryLogger
    
    private var requestResolvers: [any RequestResolving] = []
    
    private var requestHandlers: [any RequestHandling] = []

    public init() {
        logger = WalletLibraryLogger()
    }

    /// Builds the VerifiedIdClient with the set configuration from the builder.
    public func build() throws -> VerifiedIdClient {
        /// TODO: inject log consumer and access group identifier into vc sdk.
        let _ = VCServices.VerifiableCredentialSDK.initialize()
        
        let configuration = LibraryConfiguration(logger: logger,
                                                 mapper: Mapper(),
                                                 verifiedIdDecoder: VerifiedIdDecoder(),
                                                 verifiedIdEncoder: VerifiedIdEncoder())
        
        registerSupportedResolvers(with: configuration)
        registerSupportedRequestHandlers(with: configuration)
        
        let requestResolverFactory = RequestResolverFactory(resolvers: requestResolvers)
        let requestHandlerFactory = RequestHandlerFactory(requestHandlers: requestHandlers)
        return VerifiedIdClient(requestResolverFactory: requestResolverFactory,
                                requestHandlerFactory: requestHandlerFactory,
                                configuration: configuration)
    }

    /// Optional method to add a custom log consumer to VerifiedIdClient.
    public func with(logConsumer: WalletLibraryLogConsumer) -> VerifiedIdClientBuilder {
        logger.add(consumer: logConsumer)
        return self
    }
    
    private func registerSupportedResolvers(with configuration: LibraryConfiguration) {
        let openIdURLResolver = OpenIdURLRequestResolver(openIdResolver: PresentationService(), configuration: configuration)
        requestResolvers.append(openIdURLResolver)
    }
    
    private func registerSupportedRequestHandlers(with configuration: LibraryConfiguration) {
        let issuanceService = IssuanceService()
        let presentationService = PresentationService()
        let openIdHandler = OpenIdRequestHandler(configuration: configuration,
                                                 openIdResponder: presentationService,
                                                 manifestResolver: issuanceService,
                                                 verifiableCredentialRequester: issuanceService)
        requestHandlers.append(openIdHandler)
    }
}
