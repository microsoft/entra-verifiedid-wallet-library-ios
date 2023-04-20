/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import Foundation

public class ED25519PublicKey: PublicKey {
   
    public let algorithm = SupportedCurve.ED25519.rawValue
    
    public let uncompressedValue: Data
    
    public init?(x: Data) {
        guard x.count == 32 else { return nil }
        self.uncompressedValue = x
    }
}
