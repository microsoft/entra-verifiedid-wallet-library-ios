/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockIdentifierRepository: HolderIdentifierRepository
{
    private let expectedIdentifier: HolderIdentifier?
    
    private let expectedSaveErrorThrown: Error?
    
    private let expectedDeleteErrorThrown: Error?
    
    init(expectedIdentifier: HolderIdentifier? = nil, expectedErrorThrown: Error? = nil, expectedPruneErrorThrown: Error? = nil)
    {
        self.expectedIdentifier = expectedIdentifier
        self.expectedSaveErrorThrown = expectedErrorThrown
        self.expectedDeleteErrorThrown = expectedPruneErrorThrown
    }
    
    func getMainHolderIdentifier() throws -> HolderIdentifier
    {
        if let error = expectedSaveErrorThrown
        {
            throw error
        }
        else
        {
            return expectedIdentifier ?? MockHolderIdentifier()
        }
    }
    
    func pruneHolderIdentifiers() throws {
        if let error = expectedDeleteErrorThrown
        {
            throw error
        }
    }
}
