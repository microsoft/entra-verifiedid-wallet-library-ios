/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum NonceProcessorError: Error {
    case unableToSerializeDid
}

public struct NonceProcessor {
    
    public init() {}

    public func createNonce(from identifierManager: IdentifierManager? = nil) -> String? {
        do {
            let identifierManager = identifierManager ?? IdentifierService()
            let didHash = try getDidHash(from: identifierManager.fetchOrCreateMasterIdentifier().longFormDid)

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
            throw NonceProcessorError.unableToSerializeDid
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
