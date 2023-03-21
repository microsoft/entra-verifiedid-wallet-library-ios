/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Representation of the Verified Id Style configured by a Manifest implemented in 2022.
 */
public struct Manifest2022VerifiedIdStyle: VerifiedIdStyle {
    
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
    
    /// Optional url that can be used to fetch a logo for the Verified Id.
    public let logoUrl: URL?
    
    /// Optional alt text for the Verified Id logo.
    public let logoAltText: String?
}
