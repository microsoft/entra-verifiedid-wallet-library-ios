/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import CommonCrypto

public struct Sha512: Hashing {
    
    public init() {}
    
    /// Hash a message
    /// - Parameter data: The data to hash
    /// - Returns: The Sha512 hash of the data
    public func hash(data: Data) -> Data {
        var result : [UInt8] = [UInt8](repeating: 0, count:Int(CC_SHA512_DIGEST_LENGTH))
        
        data.withUnsafeBytes { (dataPtr) in
            CC_SHA512(dataPtr.bindMemory(to: UInt8.self).baseAddress, UInt32(data.count), &result)
            return
        }
        
        return Data(result)
    }
}
