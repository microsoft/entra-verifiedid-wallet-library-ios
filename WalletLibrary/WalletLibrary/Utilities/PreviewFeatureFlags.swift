/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Feature Flags that can be used to support preview features that are still under development..
 */
public struct PreviewFeatureFlag
{
    /// A preview feature for access token support from the OpenID4VCI protocol.
    public static let OpenID4VCIAccessToken = "OpenID4VCIAccessToken"
    
    /// A preview feature for Pre Auth support from the OpenID4VCI protocol.
    public static let OpenID4VCIPreAuth = "OpenID4VCIPreAuth"
    
    private var supportedPreviewFeatures: [String: Bool] = [
        OpenID4VCIAccessToken: false,
        OpenID4VCIPreAuth: false
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
