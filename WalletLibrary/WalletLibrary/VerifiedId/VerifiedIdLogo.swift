/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Holds information describing a logo.
 */
public struct VerifiedIdLogo: Equatable {
    /// Optional url that can be used to fetch a logo for the Verified Id.
    public let url: URL?
    
    /// Optional alt text for the Verified Id logo.
    public let altText: String?
}
