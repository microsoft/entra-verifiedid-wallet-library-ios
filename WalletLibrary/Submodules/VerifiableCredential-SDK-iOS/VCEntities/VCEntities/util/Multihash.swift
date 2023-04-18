/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
#if canImport(VCCrypto)
    import VCCrypto
#endif

let SHA2_256 = 0x12

struct Multihash {
    func compute(from data: Data) -> Data {
        let hashingAlgorithm = Sha256()
        let hashedData = hashingAlgorithm.hash(data: data)
        let buffer = [UInt8](hashedData)
        
        var pre = [0,0] as [UInt8]
        pre[0] = UInt8(SHA2_256)
        pre[1] = UInt8(buffer.count)
        pre.append(contentsOf: buffer)
        
        return Data(pre)
    }
}
