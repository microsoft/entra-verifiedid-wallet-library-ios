/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Feature Flags that can be used to support preview features that are still under development..
 */
public struct PreviewFeatureFlags
{
    /// A preview feature for access token support from the OpenID4VCI protocol.
    public static let OpenID4VCIAccessToken = "OpenID4VCIAccessToken"
    
    /// A preview feature for Pre Auth support from the OpenID4VCI protocol.
    public static let OpenID4VCIPreAuth = "OpenID4VCIPreAuth"
    
    /// A preview feature to support building Presentation Exchange Response through Serialization
    /// instead of using the old VC SDK
    public static let PresentationExchangeSerializationSupport = "PresentationExchangeSerializationSupport"
    
    /// A preview feature to support protocol extensions.
    public static let ProcessorExtensionSupport = "ProcessorExtensionSupport"
    
    private var supportedPreviewFeatures: [String: Bool] = [
        OpenID4VCIAccessToken: false,
        OpenID4VCIPreAuth: false,
        PresentationExchangeSerializationSupport: false,
        ProcessorExtensionSupport: false
    ]
    
    init(previewFeatureFlags: [String] = [])
    {
        for flag in previewFeatureFlags 
        {
            supportedPreviewFeatures[flag] = true
        }
    }
    
    func isPreviewFeatureSupported(_ featureFlag: String) -> Bool
    {
        return supportedPreviewFeatures[featureFlag] ?? false
    }
}
