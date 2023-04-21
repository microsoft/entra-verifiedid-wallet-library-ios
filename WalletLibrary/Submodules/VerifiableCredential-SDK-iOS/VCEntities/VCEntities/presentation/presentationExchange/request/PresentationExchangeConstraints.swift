/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents of the Constraints  from the Presentation Exchange protocol.
 *
 * @see [Presentation Exchange Spec](https://identity.foundation/presentation-exchange/#input-descriptor-object)
 */
struct PresentationExchangeConstraints: Codable, Equatable {

    /// A list of fields that must be adhered to to fulfill presentation request.
    let fields: [PresentationExchangeField]?
    
    enum CodingKeys: String, CodingKey {
        case fields
    }
    
    init(fields: [PresentationExchangeField]? = nil) {
        self.fields = fields
    }
}
