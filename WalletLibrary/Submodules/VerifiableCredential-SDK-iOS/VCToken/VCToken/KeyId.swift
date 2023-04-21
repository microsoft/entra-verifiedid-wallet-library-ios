/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCCrypto)
    import VCCrypto
#endif

struct KeyId: VCCryptoSecret {
    
    let id: UUID
    
    let accessGroup: String? = nil
    
    init(id: UUID) {
        self.id = id
    }
    
    func isValidKey() throws { }
    
    func migrateKey(fromAccessGroup oldAccessGroup: String?) throws { }

    func withUnsafeBytes(_ body: (UnsafeRawBufferPointer) throws -> Void) throws { }
}
