/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockIdentifierManager: IdentifierManager
{
    enum ExpectedError: Error
    {
        case ExpectedToThrow
    }
    
    let mockKeyId: String?
    
    let doesThrow: Bool
    
    init(mockKeyId: String?)
    {
        self.mockKeyId = mockKeyId
        self.doesThrow = false
    }
    
    init(doesThrow: Bool = false)
    {
        self.mockKeyId = "mockKeyId"
        self.doesThrow = doesThrow
    }
    
    func fetchOrCreateMasterIdentifier() throws -> Identifier
    {
        guard !doesThrow else
        {
            throw ExpectedError.ExpectedToThrow
        }
        
        return mockIdentifier(keyId: mockKeyId)
    }
    
    private func mockIdentifier(keyId: String?) -> Identifier
    {
        let uuid = UUID()
        let key = KeyContainer(keyReference: MockCryptoSecret(id: uuid), keyId: keyId ?? "")
        
        var keys: [KeyContainer] = []
        if let keyId = keyId
        {
            keys.append(key)
        }

        let identifier = Identifier(longFormDid: "did:test:1234",
                                    didDocumentKeys: keys,
                                    updateKey: key,
                                    recoveryKey: key,
                                    alias: "mock alias")
        return identifier
    }
}

