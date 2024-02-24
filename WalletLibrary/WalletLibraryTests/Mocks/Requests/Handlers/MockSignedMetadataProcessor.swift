/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockSignedMetadataProcessor: SignedCredentialMetadataProcessing
{
    enum MockError: Error
    {
        case ErrorExpected
    }
    
    private let shouldThrow: Bool
    
    init(shouldThrow: Bool)
    {
        self.shouldThrow = shouldThrow
    }
    
    func process(signedMetadata: String, credentialIssuer: String) async throws -> RootOfTrust
    {
        if shouldThrow
        {
            throw MockError.ErrorExpected
        }
        
        return RootOfTrust(verified: true, source: "")
    }
}
