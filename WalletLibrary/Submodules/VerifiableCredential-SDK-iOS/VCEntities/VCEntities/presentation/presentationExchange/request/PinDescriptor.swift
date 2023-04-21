/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct PinDescriptor: Codable, Equatable {
    let type: String?
    let length: Int
    let hash: String
    let salt: String?
    let iterations: Int?
    let alg: String?
    
    init(type: String?,
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
