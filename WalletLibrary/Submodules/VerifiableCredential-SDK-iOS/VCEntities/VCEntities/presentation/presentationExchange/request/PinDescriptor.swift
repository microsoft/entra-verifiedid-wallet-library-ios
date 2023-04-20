/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct PinDescriptor: Codable, Equatable {
    public let type: String?
    public let length: Int
    public let hash: String
    public let salt: String?
    public let iterations: Int?
    public let alg: String?
    
    public init(type: String?,
                length: Int,
                hash: String,
                salt: String?,
                iterations: Int?,
                alg: String?) {
        self.type = type
        self.length = length
        self.hash = hash
        self.salt = salt
        self.iterations = iterations
        self.alg = alg
    }
}
