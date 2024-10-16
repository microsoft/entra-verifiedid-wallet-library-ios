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
    
    private var requestProcessors: [any RequestProcessing] = []
    
    private var rootOfTrustResolver: RootOfTrustResolver?
    
    private var extensions: [VerifiedIdExtendable] = []
    
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
        registerSupportedRequestProcessors(with: configuration)
        registerVerifiedIdExtensions(with: configuration)
        
        let requestResolverFactory = RequestResolverFactory(resolvers: requestResolvers)
        let requestHandlerFactory = RequestProcessorFactory(requestHandlers: requestProcessors)
        return VerifiedIdClient(requestResolverFactory: requestResolverFactory,
                                requestHandlerFactory: requestHandlerFactory,
                                configuration: configuration)
    }
    
    /// Optional method to add support for preview features.
    public func with(previewFeatureFlags: [String]) -> VerifiedIdClientBuilder
    {
        previewFeatureFlagsSupported.append(contentsOf: previewFeatureFlags)
        return self
    }
    
    /// Optional method to add a custom Root of Trust Resolver to the VerifiedIdClient.
    public func with(rootOfTrustResolver: RootOfTrustResolver) -> VerifiedIdClientBuilder {
        self.rootOfTrustResolver = rootOfTrustResolver
        return self
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
    
    /// Optional method to add a custom Verified Id Extension to the VerifiedIdClient.
    public func with(verifiedIdExtension: VerifiedIdExtendable) -> VerifiedIdClientBuilder
    {
        self.extensions.append(verifiedIdExtension)
        return self
    }
    
    private func registerSupportedResolvers(with configuration: LibraryConfiguration) {
        let presentationService = PresentationService(correlationVector: correlationHeader,
                                                      rootOfTrustResolver: rootOfTrustResolver,
                                                      urlSession: urlSession)
        let openIdURLResolver = OpenIdURLRequestResolver(openIdResolver: presentationService,
                                                         configuration: configuration)
        requestResolvers.append(openIdURLResolver)
    }
    
    private func registerSupportedRequestProcessors(with configuration: LibraryConfiguration)
    {
        let issuanceService = IssuanceService(correlationVector: correlationHeader,
                                              rootOfTrustResolver: rootOfTrustResolver,
                                              urlSession: urlSession)
        let presentationService = PresentationService(correlationVector: correlationHeader,
                                                      rootOfTrustResolver: rootOfTrustResolver,
                                                      urlSession: urlSession)
        
        let openIdProcessor = OpenIdRequestProcessor(configuration: configuration,
                                                     openIdResponder: presentationService,
                                                     manifestResolver: issuanceService,
                                                     verifiableCredentialRequester: issuanceService)
        requestProcessors.append(openIdProcessor)
        
        let credMetadataProcessor = SignedCredentialMetadataProcessor(configuration: configuration,
                                                                      rootOfTrustResolver: rootOfTrustResolver)
        let openId4VCIProcessor = OpenId4VCIProcessor(configuration: configuration, signedMetadataProcessor: credMetadataProcessor)
        requestProcessors.append(openId4VCIProcessor)
    }
    
    private func registerVerifiedIdExtensions(with conf: LibraryConfiguration)
    {
        let extConfig = conf.createExtensionConfiguration()
        var allProcessorExtensions: [any RequestProcessorExtendable] = []
        var allPreferHeadersFromExtensions: [String] = []
        for ext in extensions
        {
            allPreferHeadersFromExtensions.append(contentsOf: ext.prefer)
            let processorExtensions = ext.createRequestProcessorExtensions(configuration: extConfig)
            allProcessorExtensions.append(contentsOf: processorExtensions)
        }
        
        for processorExtension in allProcessorExtensions
        {
            addExtensionToProcessors(ext: processorExtension)
        }
        
        for var resolver in requestResolvers 
        {
            resolver.preferHeaders.append(contentsOf: allPreferHeadersFromExtensions)
        }

    }
    
    private func addExtensionToProcessors<Ext: RequestProcessorExtendable>(ext: Ext)
    {
        for var processor in requestProcessors
        {
            if type(of: processor) == Ext.RequestProcessor.self
            {
                processor.requestProcessorExtensions.append(ext)
            }
        }
    }
}
