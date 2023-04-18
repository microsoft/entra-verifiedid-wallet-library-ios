/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import VCCrypto

struct MockCryptoSecret: VCCryptoSecret {
    
    var accessGroup: String?
    
    var id: UUID
    
    init(id: UUID) {
        self.id = id
    }
    
    func isValidKey() throws { }
    
    func migrateKey(fromAccessGroup oldAccessGroup: String?) throws { }

    func withUnsafeBytes(_ body: (UnsafeRawBufferPointer) throws -> Void) throws { }
}
