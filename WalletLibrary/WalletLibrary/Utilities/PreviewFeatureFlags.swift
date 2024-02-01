/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Feature Flags that can be used to support preview features that are still under development..
 */
public enum PreviewFeatureFlag 
{
    /// A preview feature for access token support from the OpenID4VCI protocol.
    case OpenID4VCIAccessTokenSupport
    
    /// A preview feature for Pre Auth support from the OpenID4VCI protocol.
    case OpenID4VCIPreAuthSupport
}
