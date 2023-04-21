/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

/// An ephemeral secret is one that vanishes into thin air when you are not looking at it
/// (i.e. when it goes out of scope)
final class EphemeralSecret: Secret {

    private enum EphemeralSecretError: Error {
        case secRandomCopyBytesFailed(status: OSStatus)
    }

    static var itemTypeCode: String = ""

    var accessGroup: String? = nil
    
    private(set) var id = UUID()
    private(set) var value: Data
    
    init(with data: Data, id: UUID? = nil, accessGroup: String? = nil) {
        
        // Since we practively zero out the contents of the `value` buffer
        // on deallocation, we make a separate copy of the input here
        value = Data()
        value.append(data)
        if let uuid = id {
            self.id = uuid
        }
        self.accessGroup = accessGroup
    }
    
    init(size: Int = 32) throws {
        value = Data(count:size)
        let result = value.withUnsafeMutableBytes { (secretPtr) in
            SecRandomCopyBytes(kSecRandomDefault, secretPtr.count, secretPtr.baseAddress!)
        }
        guard result == errSecSuccess else {
            throw EphemeralSecretError.secRandomCopyBytesFailed(status: result)
        }
    }
    
    init(with secret: VCCryptoSecret) throws
    {
        value = Data()
        if let internalSecret = secret as? Secret {
            try internalSecret.withUnsafeBytes { secretPtr in
                if let baseAddress = secretPtr.baseAddress, secretPtr.count > 0 {
                    let bytes = baseAddress.assumingMemoryBound(to: UInt8.self)
                    value.append(bytes, count: secretPtr.count)
                }
            }
        }
        self.id = secret.id
        self.accessGroup = secret.accessGroup
    }
    
    func withUnsafeBytes(_ body: (UnsafeRawBufferPointer) throws -> Void) throws {
        try value.withUnsafeBytes { (valuePtr) in
            try body(valuePtr)
        }
    }
    
    func isValidKey() throws {}
    
    func migrateKey(fromAccessGroup currentAccessGroup: String?) throws {
        /* Do nothing */
    }
    
    func prefix(_ maxLength: Int) -> EphemeralSecret {
        return EphemeralSecret(with: value.prefix(maxLength))
    }
    
    func suffix(_ maxLength: Int) -> EphemeralSecret {
        return EphemeralSecret(with: value.suffix(maxLength))
    }
    
    deinit {
        value.withUnsafeMutableBytes { (secretPtr) in
            let secretBytes = secretPtr.bindMemory(to: UInt8.self)
            memset_s(secretBytes.baseAddress, secretBytes.count, 0, secretBytes.count)
            return
        }
    }
}
