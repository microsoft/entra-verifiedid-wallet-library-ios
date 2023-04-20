/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents of Presentation Submission of a Presentation Exchange Response.
 *
 * @see [Presentation Exchange Spec](https://identity.foundation/presentation-exchange/#presentation-submission)
 */
public struct PresentationSubmission: Codable {
    
    /// The value of this property MUST be a unique identifier, such as a UUID.
    public let id: String
    
    /// The value of this property MUST be the id value of a valid Presentation Definition from request.
    public let definitionId: String?
    
    /// The value of this property MUST be an array of Input Descriptor Mapping Objects.
    public let inputDescriptorMap: [InputDescriptorMapping]
    
    enum CodingKeys: String, CodingKey {
        case inputDescriptorMap = "descriptor_map"
        case definitionId = "definition_id"
        case id
    }
}
