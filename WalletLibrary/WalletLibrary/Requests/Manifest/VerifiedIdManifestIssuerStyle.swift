/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Representation of Issuer Style configured by a manifest.
 */
public struct VerifiedIdManifestIssuerStyle: RequesterStyle, Equatable {
    /// The name of the issuer.
    public let name: String
    
    /// The title of the request.
    public let requestTitle: String?
    
    /// The instructions on the request.
    public let requestInstructions: String?
    
    init(name: String, requestTitle: String? = nil, requestInstructions: String? = nil) {
        self.name = name
        self.requestTitle = requestTitle
        self.requestInstructions = requestInstructions
    }
}
