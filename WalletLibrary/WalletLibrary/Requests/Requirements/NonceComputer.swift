/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCCrypto

enum NonceComputerError: Error {
    case unableToSerializeDid
}

struct NonceComputer {
    
    func createNonce(from did: String) -> String? {
        do {
            let didHash = try getDidHash(from: did)
            
            guard let prefix = createRandomURLSafeString(withSize: 32) else {
                return nil
            }
            
            return "\(prefix).\(didHash)"
            
        } catch {
            return nil
        }
    }
    
    private func getDidHash(from did: String) throws -> String {
        
        guard let serialized = did.data(using: .utf8) else {
            throw NonceComputerError.unableToSerializeDid
        }
        
        let sha = Sha512()
        let hash = sha.hash(data: serialized)
        return encodeBase64urlNoPadding(hash)
    }
    
    private func createRandomURLSafeString(withSize size: Int) -> String? {
        
        guard let randomData = NSMutableData(length: size) else {
            return nil
        }
        
        let result = SecRandomCopyBytes(kSecRandomDefault, randomData.length, randomData.mutableBytes)
        
        if result != 0 {
            return nil
        }
        
        return encodeBase64urlNoPadding(randomData as Data)
    }
    
    private func encodeBase64urlNoPadding(_ data: Data) -> String {
        var encodedHash = data.base64EncodedString()
        encodedHash = encodedHash.replacingOccurrences(of: "+", with: "-")
        encodedHash = encodedHash.replacingOccurrences(of: "/", with: "_")
        encodedHash = encodedHash.replacingOccurrences(of: "=", with: "")
        return encodedHash
    }
}
