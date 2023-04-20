/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
#if canImport(VCCrypto)
    import VCCrypto
#endif
#if canImport(VCToken)
    import VCToken
#endif

enum JwePasswordProtectionError : Error {
    case invalidContentType
}

public struct JwePasswordProtectionMethod : BackupProtectionMethod {
    
    private struct Constants {
        static let Algorithm = "PBES2-HS512+A256KW"
        static let Method = "A256CBC-HS512"
        static let SaltLength = 8
        static let SaltIterations = UInt(100 * 1000)
    }
    
    let password: String
    
    public init(password: String) {
        self.password = password
    }

    public func wrap(unprotectedBackupData: UnprotectedBackupData) throws -> ProtectedBackupData {

        // Generate a salt
        let salt = try EphemeralSecret(size: Constants.SaltLength)
        
        // Construct the headers
        let headers = Header(type: nil,
                             algorithm: Constants.Algorithm,
                             encryptionMethod: Constants.Method,
                             jsonWebKey: nil,
                             keyId: nil,
                             contentType: unprotectedBackupData.type,
                             pbes2SaltInput: salt.value.base64URLEncodedString(),
                             pbes2Count: Constants.SaltIterations)
        
        // Encrypt
        let token = try PbesJwe().encrypt(unprotectedBackupData.encoded,
                                          with: self.password,
                                          using: headers)
        
        // Encode and return
        return try JwePasswordProtectedBackupData(content: JweEncoder().encode(token))
    }
    
    public func unwrap(protectedBackupData: ProtectedBackupData) throws -> UnprotectedBackupData {
        
        // Decode
        let token = try JweDecoder().decode(token: protectedBackupData.serialize())
        guard let type = token.headers.contentType else {
            throw JwePasswordProtectionError.invalidContentType
        }
        
        // Decrypt
        let decrypted = try PbesJwe().decrypt(token, with: self.password)
        
        // Return
        return UnprotectedBackupData(type: type, encoded: decrypted)
    }
}
