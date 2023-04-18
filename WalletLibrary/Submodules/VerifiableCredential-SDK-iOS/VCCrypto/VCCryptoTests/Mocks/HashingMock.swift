/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/


import Foundation
@testable import VCCrypto

final class HashingMock: Hashing {
    
    static var wasHashCalled = false
    
    let hashingResult: Data
    
    init(hashingResult: Data = Data(count: 32)) {
        self.hashingResult = hashingResult
    }
    
    func hash(data: Data) -> Data {
        Self.wasHashCalled = true
        return hashingResult
    }
}
