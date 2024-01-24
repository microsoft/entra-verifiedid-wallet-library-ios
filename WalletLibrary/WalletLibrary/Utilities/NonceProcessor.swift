/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum NonceProcessorError: Error 
{
    case UnableToSerializeDid
}

struct NonceProcessor 
{
    func createNonce(fromIdentifier did: String) -> String? 
    {
        do 
        {
            let didHash = try getDidHash(from: did)
            guard let prefix = createRandomURLSafeString(withSize: 32) else 
            {
                return nil
            }

            return "\(prefix).\(didHash)"

        } 
        catch
        {
            return nil
        }
    }

    private func getDidHash(from did: String) throws -> String 
    {

        guard let serialized = did.data(using: .utf8) else 
        {
            throw NonceProcessorError.UnableToSerializeDid
        }

        let sha = Sha512()
        let hash = sha.hash(data: serialized)
        return hash.base64URLEncodedWithNoPaddingString()
    }

    private func createRandomURLSafeString(withSize size: Int) -> String? 
    {
        guard let randomData = NSMutableData(length: size) else 
        {
            return nil
        }

        let result = SecRandomCopyBytes(kSecRandomDefault, randomData.length, randomData.mutableBytes)

        if result != 0 
        {
            return nil
        }

        return (randomData as Data).base64URLEncodedWithNoPaddingString()
    }
}
