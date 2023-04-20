/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents of Verifiable Presentation Response Description, a property within a OIDC Presentation Response
 * which describes how to parse the VP Token.
 */
public struct VPTokenResponseDescription: Codable {
    
    /// The presentation submission that describes what is being presented.
    public let presentationSubmission: PresentationSubmission?
    
    enum CodingKeys: String, CodingKey {
        case presentationSubmission = "presentation_submission"
    }
}
