/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
@testable import VCNetworking

struct MockDecoder: Decoding {
    typealias ResponseBody = MockObject
    
    let jsonDecoder = JSONDecoder()
    
    func decode(data: Data) throws -> MockObject {
        return try jsonDecoder.decode(MockObject.self, from: data)
    }
}

