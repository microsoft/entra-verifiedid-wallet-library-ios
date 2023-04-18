/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

/// status of a successful initialization
public enum VCSDKInitStatus
{
    case success
}

/// Class used to Initialize the SDK.
public class VerifiableCredentialSDK {
    
    public static let identifierService = IdentifierService()
    
    /// Initialized the SDK.
    /// Returns:  Result<VCSDKInitStatus>, if successfully initialized the SDK.
    ///        Result<Error>, if there was an error, and unable to initialize SDK.
    public static func initialize(logConsumer: VCLogConsumer = DefaultVCLogConsumer(),
                                  accessGroupIdentifier: String? = nil,
                                  discoveryUrl: String? = nil) -> Result<VCSDKInitStatus, Error> {

        /// Step 1: Add Log to VCSDKLog shared instance.
        VCSDKLog.sharedInstance.add(consumer: logConsumer)
        
        /// Step 2: Set access group identifier for key chain.
        if let accessGroupIdentifier = accessGroupIdentifier {
            VCSDKConfiguration.sharedInstance.setAccessGroupIdentifier(with: accessGroupIdentifier)
        }
        
        if let discoveryUrl = discoveryUrl {
            VCSDKConfiguration.sharedInstance.setDiscoveryUrl(with: discoveryUrl)
        }
        
        /// Step 4: return success.
        return .success(.success)
    }
}
