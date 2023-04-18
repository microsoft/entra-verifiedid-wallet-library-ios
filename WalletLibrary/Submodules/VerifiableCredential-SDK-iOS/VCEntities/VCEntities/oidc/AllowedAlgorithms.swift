/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct AllowedAlgorithms: Codable, Equatable {

    public let algorithms: [String]?

    enum CodingKeys: String, CodingKey {
        case algorithms = "alg"
    }
    
    public init(algorithms: [String]? = nil) {
        self.algorithms = algorithms
    }
}

public enum SupportedAlgorithms: String {
    case es256k = "ES256K"
}
