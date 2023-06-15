/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCServices)
    import VCServices
#endif

/**
 * The VerifiedIdClientBuilder configures VerifiedIdClient with any additional options.
 */
public class VerifiedIdClientBuilder {

    var keychainAccessGroupIdentifier: String?
    
    private var correlationHeader: VerifiedIdCorrelationHeader?
    
    private var logger: WalletLibraryLogger
    
    private var requestResolvers: [any RequestResolving] = []
    
    private var requestHandlers: [any RequestHandling] = []
    
    public init() {
        logger = WalletLibraryLogger()
    }

    /// Builds the VerifiedIdClient with the set configuration from the builder.
    public func build() -> VerifiedIdClient {

        let vcLogConsumer = WalletLibraryVCSDKLogConsumer(logger: logger)
        let _ = VerifiableCredentialSDK.initialize(logConsumer: vcLogConsumer,
                                                   accessGroupIdentifier: keychainAccessGroupIdentifier)
        
        let configuration = LibraryConfiguration(logger: logger,
                                                 mapper: Mapper(),
                                                 correlationHeader: correlationHeader,
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
    
    /// Optional method to add a custom Correlation Header to the VerifiedIdClient.
    public func with(verifiedIdCorrelationHeader: VerifiedIdCorrelationHeader) -> VerifiedIdClientBuilder {
        self.correlationHeader = verifiedIdCorrelationHeader
        return self
    }
    
    /// Optional method to use the given value to specify what Keychain Access Group keys should be stored in.
    public func with(keychainAccessGroupIdentifier: String) -> VerifiedIdClientBuilder {
        self.keychainAccessGroupIdentifier = keychainAccessGroupIdentifier
        return self
    }
    
    private func registerSupportedResolvers(with configuration: LibraryConfiguration) {
        let openIdURLResolver = OpenIdURLRequestResolver(openIdResolver: PresentationService(),
                                                         configuration: configuration)
        requestResolvers.append(openIdURLResolver)
    }
    
    private func registerSupportedRequestHandlers(with configuration: LibraryConfiguration) {
        let issuanceService = IssuanceService(correlationVector: correlationHeader)
        let presentationService = PresentationService(correlationVector: correlationHeader)
        let openIdHandler = OpenIdRequestHandler(configuration: configuration,
                                                 openIdResponder: presentationService,
                                                 manifestResolver: issuanceService,
                                                 verifiableCredentialRequester: issuanceService)
        requestHandlers.append(openIdHandler)
    }
}
