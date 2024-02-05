/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Utilities such as logger, mapper, httpclient (post private preview) that are configured in builder and
 * all of library will use.
 */
class LibraryConfiguration {

    let logger: WalletLibraryLogger

    let mapper: Mapping
    
    let verifiedIdDecoder: VerifiedIdDecoding
    
    let verifiedIdEncoder: VerifiedIdEncoding
    
    let networking: LibraryNetworking
    
    let identifierManager: IdentifierManager
    
    let previewFeatureFlags: PreviewFeatureFlags

    init(logger: WalletLibraryLogger = WalletLibraryLogger(),
         mapper: Mapping = Mapper(),
         networking: LibraryNetworking? = nil,
         verifiedIdDecoder: VerifiedIdDecoding = VerifiedIdDecoder(),
         verifiedIdEncoder: VerifiedIdEncoding = VerifiedIdEncoder(),
         identifierManager: IdentifierManager? = nil,
         previewFeatureFlags: PreviewFeatureFlags = PreviewFeatureFlags()) {
        self.logger = logger
        self.mapper = mapper
        self.networking = networking ?? WalletLibraryNetworking(urlSession: URLSession.shared,
                                                                logger: logger,
                                                                verifiedIdCorrelationHeader: nil)
        self.verifiedIdDecoder = verifiedIdDecoder
        self.verifiedIdEncoder = verifiedIdEncoder
        self.identifierManager = identifierManager ?? VerifiableCredentialSDK.identifierService
        self.previewFeatureFlags = previewFeatureFlags
    }
    
    /// Helper function to determine if a preview feature flag is supported
    func isPreviewFeatureFlagSupported(_ featureFlag: String) -> Bool
    {
        return previewFeatureFlags.isPreviewFeatureSupported(featureFlag)
    }
}
