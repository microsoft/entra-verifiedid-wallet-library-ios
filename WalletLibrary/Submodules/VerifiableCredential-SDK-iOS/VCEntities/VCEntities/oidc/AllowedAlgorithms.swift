/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct AllowedAlgorithms: Codable, Equatable {

    let algorithms: [String]?

    enum CodingKeys: String, CodingKey {
        case algorithms = "alg"
    }
    
    init(algorithms: [String]? = nil) {
        self.algorithms = algorithms
    }
}

enum SupportedAlgorithms: String {
    case es256k = "ES256K"
}
