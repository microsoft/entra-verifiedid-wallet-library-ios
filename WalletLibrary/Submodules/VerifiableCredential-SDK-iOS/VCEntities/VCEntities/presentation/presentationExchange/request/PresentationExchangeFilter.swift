/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents of the Presentation Exchnage Filter inside of a Input Descriptor Field  from the Presentation Exchange protocol.
 *
 * @see [Presentation Exchange Spec](https://identity.foundation/presentation-exchange/#input-descriptor-object)
 */
struct PresentationExchangeFilter: Codable, Equatable {
    
    /// type of value (ex. String)
    let type: String?
    
    /// JSON Schema descriptor
    let pattern: NSRegularExpression?
    
    enum CodingKeys: String, CodingKey {
        case type, pattern
    }
    
    init(type: String? = nil, pattern: NSRegularExpression? = nil) {
        self.type = type
        self.pattern = pattern
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        if let pattern = try values.decodeIfPresent(String.self, forKey: .pattern) {
            self.pattern = try NSRegularExpression(pattern: pattern)
        } else {
            self.pattern = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(pattern?.pattern, forKey: .pattern)
    }
}
