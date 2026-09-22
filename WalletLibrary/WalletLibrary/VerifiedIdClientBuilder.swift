/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The VerifiedIdClientBuilder configures VerifiedIdClient with any additional options.
 */
public class VerifiedIdClientBuilder 
{
    var keychainAccessGroupIdentifier: String?
    
    private var correlationHeader: VerifiedIdCorrelationHeader?
    
    private var urlSession: URLSession = URLSession.shared
    
    private var logger: WalletLibraryLogger
    
    private var requestResolvers: [any RequestResolving] = []
    
    private var requestProcessors: [any RequestProcessing] = []
    
    private var rootOfTrustResolver: RootOfTrustResolver?
    
    private var extensions: [VerifiedIdExtendable] = []
    
    private var previewFeatureFlagsSupported: [String] = []
    
    private var identifiers: [HolderIdentifier] = []
    
    private let identifierRepository: HolderIdentifierRepository?

    var identifierRepositoryFactory: (WalletLibraryLogger) -> HolderIdentifierRepository = {
        IdentifierRepository(logger: $0)
    }

    var legacyHolderIdentifierLoader: () throws -> HolderIdentifier = {
        let identifier = try VerifiableCredentialSDK.identifierService.fetchOrCreateMasterIdentifier()
        return try identifier.toHolderIdentifier(cryptoOperations: CryptoOperations())
    }
    
    public init() 
    {
        self.logger = WalletLibraryLogger()
        self.identifierRepository = nil
    }
    
    /// Internal init to help with testing.
    init(identifierRepository: HolderIdentifierRepository)
    {
        self.logger = WalletLibraryLogger()
        self.identifierRepository = identifierRepository
    }

    /// Builds the VerifiedIdClient with the set configuration from the builder.
    public func build() -> VerifiedIdClient 
    {

        let previewFeatureFlags = PreviewFeatureFlags(previewFeatureFlags: previewFeatureFlagsSupported)
        let vcLogConsumer = WalletLibraryVCSDKLogConsumer(logger: logger)
        let _ = VerifiableCredentialSDK.initialize(logConsumer: vcLogConsumer,
                                                   accessGroupIdentifier: keychainAccessGroupIdentifier)
        
        let walletLibraryNetworking = WalletLibraryNetworking(urlSession: urlSession,
                                                              logger: logger,
                                                              correlationHeader: correlationHeader)
        
        let selection = getAllIdentifiers(previewFeatureFlags: previewFeatureFlags)
        
        let configuration = LibraryConfiguration(logger: logger,
                                                 mapper: Mapper(),
                                                 networking: walletLibraryNetworking,
                                                 verifiedIdDecoder: VerifiedIdDecoder(),
                                                 verifiedIdEncoder: VerifiedIdEncoder(),
                                                 previewFeatureFlags: previewFeatureFlags,
                                                 identifiers: selection.identifiers,
                                                 identifierLoadingError: selection.error,
                                                 isDefaultHolderIdentifierFIPSCompliant: selection.isFIPSCompliant)
        
        requestResolvers.removeAll()
        requestProcessors.removeAll()
        registerSupportedResolvers(with: configuration)
        registerSupportedRequestProcessors(with: configuration)
        registerVerifiedIdExtensions(with: configuration)
        
        let requestResolverFactory = RequestResolverFactory(resolvers: requestResolvers)
        let requestHandlerFactory = RequestProcessorFactory(requestHandlers: requestProcessors)
        return VerifiedIdClient(requestResolverFactory: requestResolverFactory,
                                requestHandlerFactory: requestHandlerFactory,
                                configuration: configuration)
    }
    
    private func getAllIdentifiers(previewFeatureFlags: PreviewFeatureFlags)
        -> (identifiers: [HolderIdentifier], error: Error?, isFIPSCompliant: Bool)
    {
        var selectedIdentifiers = identifiers
        var primaryError: Error?

        if previewFeatureFlags.isPreviewFeatureSupported(PreviewFeatureFlags.FIPSCompliantIdentifier)
        {
            do
            {
                let holderIdentifier = try getMainHolderIdentifier(previewFeatureFlags: previewFeatureFlags)
                selectedIdentifiers.insert(holderIdentifier, at: 0)
                return (selectedIdentifiers, nil,
                        holderIdentifier.method == "did:jwk" && holderIdentifier.algorithm == "ES256")
            }
            catch
            {
                primaryError = error
                logger.logError(message: "Unable to load the FIPS holder identifier.")
            }
        }

        do
        {
            selectedIdentifiers.append(try legacyHolderIdentifierLoader())
        }
        catch
        {
            primaryError = primaryError ?? error
            logger.logError(message: "Unable to load the legacy holder identifier.")
        }

        return (selectedIdentifiers, selectedIdentifiers.isEmpty ? primaryError : nil, false)
    }
    
    private func getMainHolderIdentifier(previewFeatureFlags: PreviewFeatureFlags) throws -> HolderIdentifier
    {
        let identifierRepository = identifierRepository ?? identifierRepositoryFactory(logger)
        if previewFeatureFlags.isPreviewFeatureSupported(PreviewFeatureFlags.IdentifierPruning)
        {
            do
            {
                try identifierRepository.pruneHolderIdentifiers()
            }
            catch
            {
                logger.logWarning(message: "Unable to prune holder identifiers from repository.")
            }
        }
        
        return try identifierRepository.getMainHolderIdentifier()
    }
    
    /// Optional method to add new Identifiers to Wallet Library..
    public func with(identifier: HolderIdentifier) -> VerifiedIdClientBuilder
    {
        identifiers.append(identifier)
        return self
    }
    
    /// Optional method to add support for preview features.
    public func with(previewFeatureFlags: [String]) -> VerifiedIdClientBuilder
    {
        previewFeatureFlagsSupported.append(contentsOf: previewFeatureFlags)
        return self
    }
    
    /// Optional method to add a custom Root of Trust Resolver to the VerifiedIdClient.
    public func with(rootOfTrustResolver: RootOfTrustResolver) -> VerifiedIdClientBuilder 
    {
        self.rootOfTrustResolver = rootOfTrustResolver
        return self
    }

    /// Optional method to add a custom log consumer to VerifiedIdClient.
    public func with(logConsumer: WalletLibraryLogConsumer) -> VerifiedIdClientBuilder 
    {
        logger.add(consumer: logConsumer)
        return self
    }
    
    /// Optional method to add a custom Correlation Header to the VerifiedIdClient.
    public func with(verifiedIdCorrelationHeader: VerifiedIdCorrelationHeader) -> VerifiedIdClientBuilder 
    {
        self.correlationHeader = verifiedIdCorrelationHeader
        return self
    }
    
    /// Optional method to add a custom URLSession to the VerifiedIdClient.
    public func with(urlSession: URLSession) -> VerifiedIdClientBuilder 
    {
        self.urlSession = urlSession
        return self
    }
    
    /// Specifies the keychain access group. Passing nil clears any previously configured group.
    public func with(keychainAccessGroupIdentifier: String?) -> VerifiedIdClientBuilder
    {
        self.keychainAccessGroupIdentifier = keychainAccessGroupIdentifier
        return self
    }
    
    /// Optional method to add a custom Verified Id Extension to the VerifiedIdClient.
    public func with(verifiedIdExtension: VerifiedIdExtendable) -> VerifiedIdClientBuilder
    {
        self.extensions.append(verifiedIdExtension)
        return self
    }
    
    private func registerSupportedResolvers(with configuration: LibraryConfiguration) 
    {
        let presentationService = OpenIdPresentationRequestValidator(correlationVector: correlationHeader,
                                                                     rootOfTrustResolver: rootOfTrustResolver,
                                                                     urlSession: urlSession)
        let openIdURLResolver = OpenIdURLRequestResolver(validator: presentationService,
                                                         configuration: configuration)
        requestResolvers.append(openIdURLResolver)
    }
    
    private func registerSupportedRequestProcessors(with configuration: LibraryConfiguration)
    {
        let issuanceService = IssuanceService(correlationVector: correlationHeader,
                                              rootOfTrustResolver: rootOfTrustResolver, 
                                              identifierFactory: configuration.identifierFactory,
                                              logger: configuration.logger, 
                                              urlSession: urlSession)
        
        let openIdProcessor = OpenIdRequestProcessor(configuration: configuration,
                                                     manifestResolver: issuanceService,
                                                     verifiableCredentialRequester: issuanceService)
        requestProcessors.append(openIdProcessor)
        
        let credMetadataProcessor = SignedCredentialMetadataProcessor(configuration: configuration,
                                                                      rootOfTrustResolver: rootOfTrustResolver)
        let openId4VCIProcessor = OpenId4VCIProcessor(configuration: configuration, 
                                                      signedMetadataProcessor: credMetadataProcessor)
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
