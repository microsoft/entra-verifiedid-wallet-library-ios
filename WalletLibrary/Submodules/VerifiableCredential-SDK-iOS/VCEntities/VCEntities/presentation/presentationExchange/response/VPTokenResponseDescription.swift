/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents of Verifiable Presentation Response Description, a property within a OIDC Presentation Response
 * which describes how to parse the VP Token.
 */
struct VPTokenResponseDescription: Codable {
    
    /// The presentation submission that describes what is being presented.
    let presentationSubmission: [PresentationSubmission]
    
    enum CodingKeys: String, CodingKey {
        case presentationSubmission = "presentation_submission"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if presentationSubmission.count == 1,
           let onlySubmission = presentationSubmission.first
        {
            try container.encode(onlySubmission, forKey: .presentationSubmission)
        }
        else
        {
            try container.encode(self.presentationSubmission, forKey: .presentationSubmission)
        }
    }
}
