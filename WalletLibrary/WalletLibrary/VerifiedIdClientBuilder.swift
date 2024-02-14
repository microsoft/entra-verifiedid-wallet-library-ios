/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The VerifiedIdClientBuilder configures VerifiedIdClient with any additional options.
 */
public class VerifiedIdClientBuilder {

    var keychainAccessGroupIdentifier: String?
    
    private var correlationHeader: VerifiedIdCorrelationHeader?
    
    private var urlSession: URLSession = URLSession.shared
    
    private var logger: WalletLibraryLogger
    
    private var requestResolvers: [any RequestResolving] = []
    
    private var requestHandlers: [any RequestHandling] = []
    
    private var identifierManager: IdentifierManager?
    
    private var rootOfTrustResolver: RootOfTrustResolver?
    
    private var previewFeatureFlagsSupported: [String] = []
    
    public init() {
        logger = WalletLibraryLogger()
    }

    /// Builds the VerifiedIdClient with the set configuration from the builder.
    public func build() -> VerifiedIdClient {

        let previewFeatureFlags = PreviewFeatureFlags(previewFeatureFlags: previewFeatureFlagsSupported)
        let vcLogConsumer = WalletLibraryVCSDKLogConsumer(logger: logger)
        let _ = VerifiableCredentialSDK.initialize(logConsumer: vcLogConsumer,
                                                   accessGroupIdentifier: keychainAccessGroupIdentifier)
        
        /// TODO: update to new Identifier logic once designed.
        let identifierManager: IdentifierManager = VerifiableCredentialSDK.identifierService
        
        let walletLibraryNetworking = WalletLibraryNetworking(urlSession: urlSession,
                                                              logger: logger,
                                                              correlationHeader: correlationHeader)
        
        let configuration = LibraryConfiguration(logger: logger,
                                                 mapper: Mapper(),
                                                 networking: walletLibraryNetworking,
                                                 verifiedIdDecoder: VerifiedIdDecoder(),
                                                 verifiedIdEncoder: VerifiedIdEncoder(),
                                                 identifierManager: identifierManager,
                                                 previewFeatureFlags: previewFeatureFlags)
        
        registerSupportedResolvers(with: configuration)
        registerSupportedRequestHandlers(with: configuration)
        
        let requestResolverFactory = RequestResolverFactory(resolvers: requestResolvers)
        let requestHandlerFactory = RequestHandlerFactory(requestHandlers: requestHandlers)
        return VerifiedIdClient(requestResolverFactory: requestResolverFactory,
                                requestHandlerFactory: requestHandlerFactory,
                                configuration: configuration)
    }
    
    public func with(previewFeatureFlags: [String]) -> VerifiedIdClientBuilder {
        self.previewFeatureFlagsSupported.append(contentsOf: previewFeatureFlags)
        return self
    }

    /// Optional method to add a custom log consumer to VerifiedIdClient.
    public func with(logConsumer: WalletLibraryLogConsumer) -> VerifiedIdClientBuilder {
        logger.add(consumer: logConsumer)
        return self
    }
    
    public func with(identifierManager: IdentifierManager) -> VerifiedIdClientBuilder {
        self.identifierManager = identifierManager
        return self
    }
    
    public func with(rootOfTrustResolver: RootOfTrustResolver) -> VerifiedIdClientBuilder {
        self.rootOfTrustResolver = rootOfTrustResolver
        return self
    }
    
    /// Optional method to add a custom Correlation Header to the VerifiedIdClient.
    public func with(verifiedIdCorrelationHeader: VerifiedIdCorrelationHeader) -> VerifiedIdClientBuilder {
        self.correlationHeader = verifiedIdCorrelationHeader
        return self
    }
    
    /// Optional method to add a custom URLSession to the VerifiedIdClient.
    public func with(urlSession: URLSession) -> VerifiedIdClientBuilder {
        self.urlSession = urlSession
        return self
    }
    
    /// Optional method to use the given value to specify what Keychain Access Group keys should be stored in.
    public func with(keychainAccessGroupIdentifier: String) -> VerifiedIdClientBuilder {
        self.keychainAccessGroupIdentifier = keychainAccessGroupIdentifier
        return self
    }
    
    private func registerSupportedResolvers(with configuration: LibraryConfiguration) {
        let openIdURLResolver = OpenIdURLRequestResolver(openIdResolver: PresentationService(identifierService: identifierManager,
                                                                                             rootOfTrustResolver: rootOfTrustResolver,
                                                                                             urlSession: urlSession),
                                                         configuration: configuration)
        requestResolvers.append(openIdURLResolver)
    }
    
    private func registerSupportedRequestHandlers(with configuration: LibraryConfiguration) {
        // TODO: inject networking client into Services.
        let issuanceService = IssuanceService(correlationVector: correlationHeader,
                                              identifierManager: identifierManager,
                                              rootOfTrustResolver: rootOfTrustResolver,
                                              urlSession: urlSession)
        let presentationService = PresentationService(correlationVector: correlationHeader,
                                                      identifierService: identifierManager,
                                                      rootOfTrustResolver: rootOfTrustResolver,
                                                      urlSession: urlSession)
        let openIdHandler = OpenIdRequestHandler(configuration: configuration,
                                                 openIdResponder: presentationService,
                                                 manifestResolver: issuanceService,
                                                 verifiableCredentialRequester: issuanceService)
        requestHandlers.append(openIdHandler)
        
        let openId4VCIHandler = OpenId4VCIHandler(configuration: configuration)
        requestHandlers.append(openId4VCIHandler)
    }
}
