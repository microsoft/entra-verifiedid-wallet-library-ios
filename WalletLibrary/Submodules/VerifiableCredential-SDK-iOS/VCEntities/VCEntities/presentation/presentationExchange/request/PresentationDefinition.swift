/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents of the Presentation Definition from the Presentation Exchange protocol.
 *
 * @see [Presentation Exchange Spec](https://identity.foundation/presentation-exchange/#presentation-definition)
 */
struct PresentationDefinition: Codable, Equatable {
    
    /// Unique identifier of a presentation definition.
    let id: String?
    
    /// Describes the information a Verifier requires of a Holder
    let inputDescriptors: [PresentationInputDescriptor]?
    
    /// Describes how a Holder can obtain requested information if they do not have it already.
    let issuance: [String]?
    
    init(id: String?,
                inputDescriptors: [PresentationInputDescriptor]?,
                issuance: [String]?) {
        self.id = id
        self.inputDescriptors = inputDescriptors
        self.issuance = issuance
    }
    
    enum CodingKeys: String, CodingKey {
        case inputDescriptors = "input_descriptors"
        case id, issuance
    }
}
