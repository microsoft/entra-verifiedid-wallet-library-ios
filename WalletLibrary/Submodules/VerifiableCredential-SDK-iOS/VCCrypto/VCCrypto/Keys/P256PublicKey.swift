/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/// A P256 Public Key.
class P256PublicKey: PublicKey {
   
    let algorithm = SupportedCurve.P256.rawValue
    
    let x: Data
    let y: Data
    let uncompressedValue: Data
    
    init?(uncompressedPublicKey: Data) {
        // Check if the data is long enough to represent a P-256 public key (64 bytes)
        if uncompressedPublicKey.count != 64 {
            return nil
        }
        
        // Split the data into X and Y coordinates (32 bytes each)
        self.x = uncompressedPublicKey.prefix(32)
        self.y = uncompressedPublicKey.suffix(32)
        self.uncompressedValue = uncompressedPublicKey
    }
    
    init?(x: Data, y: Data) {
        guard x.count == 32 else { return nil }
        guard y.count == 32 else { return nil }
        
        self.x = x
        self.y = y
        
        var value = Data()
        value.append(x)
        value.append(y)
        self.uncompressedValue = value
    }
}
