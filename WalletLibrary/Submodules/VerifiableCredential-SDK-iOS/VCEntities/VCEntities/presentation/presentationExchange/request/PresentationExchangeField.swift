/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents of the Constraints Field property  from the Presentation Exchange protocol.
 *
 * @see [Presentation Exchange Spec](https://identity.foundation/presentation-exchange/#input-descriptor-object)
 */
struct PresentationExchangeField: Codable, Equatable {

    /// An Array of JSON Path expressions that select a target value from the input.
    let path: [String]?
    
    /// Optional reason for this constraint.
    let purpose: String?
    
    /// Optonal JSON Schema descriptor used to filter against the values
    /// returned from evaluation of the JSONPath string expressions in the path array
    let filter: PresentationExchangeFilter?
    
    enum CodingKeys: String, CodingKey {
        case path, purpose, filter
    }
    
    init(path: [String]? = nil,
         purpose: String? = nil,
         filter: PresentationExchangeFilter? = nil) {
        self.path = path
        self.purpose = purpose
        self.filter = filter
    }
}
