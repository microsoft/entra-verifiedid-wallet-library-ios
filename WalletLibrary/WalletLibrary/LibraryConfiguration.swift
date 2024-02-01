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
    
    let correlationHeader: VerifiedIdCorrelationHeader?
    
    let identifierManager: IdentifierManager
    
    let previewFeatureFlagsSupported: [PreviewFeatureFlag]

    init(logger: WalletLibraryLogger,
         mapper: Mapping,
         correlationHeader: VerifiedIdCorrelationHeader? = nil,
         verifiedIdDecoder: VerifiedIdDecoding = VerifiedIdDecoder(),
         verifiedIdEncoder: VerifiedIdEncoding = VerifiedIdEncoder(),
         identifierManager: IdentifierManager? = nil,
         previewFeatureFlagsSupported: [PreviewFeatureFlag] = []) {
        self.logger = logger
        self.mapper = mapper
        self.correlationHeader = correlationHeader
        self.verifiedIdDecoder = verifiedIdDecoder
        self.verifiedIdEncoder = verifiedIdEncoder
        self.identifierManager = identifierManager ?? VerifiableCredentialSDK.identifierService
        self.previewFeatureFlagsSupported = previewFeatureFlagsSupported
    }
    
    /// Helper function to determine if a preview feature flag is supported
    func isPreviewFeatureFlagSupported(_ featureFlag: PreviewFeatureFlag) -> Bool
    {
        return previewFeatureFlagsSupported.contains(featureFlag)
    }
}
