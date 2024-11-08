/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockIdentifierRepository: HolderIdentifierRepository
{
    private let expectedIdentifier: HolderIdentifier?
    
    private let expectedErrorThrown: Error?
    
    init(expectedIdentifier: HolderIdentifier? = nil, expectedErrorThrown: Error? = nil)
    {
        self.expectedIdentifier = expectedIdentifier
        self.expectedErrorThrown = expectedErrorThrown
    }
    
    func getMainHolderIdentifier() throws -> HolderIdentifier
    {
        if let error = expectedErrorThrown
        {
            throw error
        }
        else
        {
            return expectedIdentifier ?? MockHolderIdentifier()
        }
    }
}
