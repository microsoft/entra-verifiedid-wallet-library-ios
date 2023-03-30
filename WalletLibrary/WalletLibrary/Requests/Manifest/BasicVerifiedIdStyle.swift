/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The basic look and feel of a Verified Id.
 */
public struct BasicVerifiedIdStyle: VerifiedIdStyle {
    
    /// The name of the Verified Id.
    public let name: String
    
    /// The name of the issuer of the Verified Id.
    public let issuer: String
    
    /// The background color of the Verified Id.
    public let backgroundColor: String
    
    /// The text color of the Verified Id.
    public let textColor: String
    
    /// The description of the Verified Id.
    public let description: String
    
    /// Optional logo for the Verified Id.
    public let logo: VerifiedIdLogo?
}
