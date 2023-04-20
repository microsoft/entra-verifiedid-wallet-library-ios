/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import VCEntities

struct MockCodableObject: Codable {
    let test: Dictionary<String, Any>
    
    enum CodingKeys: String, CodingKey {
        case test
    }
    
    init(test: Dictionary<String, Any>) {
        self.test = test
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        test = try values.decode(Dictionary<String, Any>.self, forKey: .test)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(test, forKey: .test)
    }
}
