/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import Foundation

enum PublicKeyFormat: UInt8 {
    case uncompressed = 0x04
}

public class Secp256k1PublicKey: PublicKey {
    public let x: Data
    public let y: Data
    
    public let algorithm = SupportedCurve.Secp256k1.rawValue
    
    public var uncompressedValue: Data {
        var value = Data()
        value.append(PublicKeyFormat.uncompressed.rawValue)
        value.append(x)
        value.append(y)
        return value
    }
    
    public init?(uncompressedPublicKey: Data) {
        guard uncompressedPublicKey.count == 65 else { return nil }
        
        x = uncompressedPublicKey.subdata(in: 1..<33)
        y = uncompressedPublicKey.subdata(in: 33..<65)
    }
    
    public init?(x: Data, y: Data) {
        guard x.count == 32 else { return nil }
        guard y.count == 32 else { return nil }
        
        self.x = x
        self.y = y
    }
}
