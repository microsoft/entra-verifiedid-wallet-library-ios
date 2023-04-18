/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Property of Requested Claims in an OIDC request that describes the verifiable presentation token requested.
public struct RequestedVPToken: Codable, Equatable {
    
    /// Description of the vp token requested.
    public let presentationDefinition: PresentationDefinition?
    
    public init(presentationDefinition: PresentationDefinition?) {
        self.presentationDefinition = presentationDefinition
    }

    enum CodingKeys: String, CodingKey {
        case presentationDefinition = "presentation_definition"
    }
}
