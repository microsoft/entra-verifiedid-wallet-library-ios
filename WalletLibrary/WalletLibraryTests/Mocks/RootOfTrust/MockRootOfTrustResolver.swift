/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockRootOfTrustResolver: RootOfTrustResolver
{
    enum ExpectedError: Error
    {
        case expectedToBeThrown
    }
    
    private let shouldThrowError: Bool
    
    init(shouldThrowError: Bool = false)
    {
        self.shouldThrowError = shouldThrowError
    }
    
    func resolve(from identifier: IdentifierMetadata) async throws -> RootOfTrust
    {
        if shouldThrowError
        {
            throw ExpectedError.expectedToBeThrown
        }
        
        return RootOfTrust(verified: true, source: "mockSource")
    }
}
