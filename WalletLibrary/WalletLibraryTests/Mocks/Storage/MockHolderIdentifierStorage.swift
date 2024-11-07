/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockHolderIdentifierStorage: HolderIdentifierStorage
{
    private let expectedErrorToThrowForFetching: Error?
    
    private let expectedErrorToThrowForStoring: Error?
    
    private let expectedHolderIdentifierProperties: [StoredHolderIdentifierProperties]
    
    init(expectedErrorToThrowForFetching: Error?,
         expectedErrorToThrowForStoring: Error?,
         expectedHolderIdentifierProperties: [StoredHolderIdentifierProperties] = [])
    {
        self.expectedErrorToThrowForFetching = expectedErrorToThrowForFetching
        self.expectedErrorToThrowForStoring = expectedErrorToThrowForStoring
        self.expectedHolderIdentifierProperties = expectedHolderIdentifierProperties
    }
    
    func fetchStoredHolderIdentifiers() throws -> [StoredHolderIdentifierProperties]
    {
        if let error = expectedErrorToThrowForFetching
        {
            throw error
        }
        
        return expectedHolderIdentifierProperties
    }
    
    func storeHolderIdentifier(holder: any WalletLibrary.HolderIdentifier, keyId: UUID) throws 
    {
        if let error = expectedErrorToThrowForStoring
        {
            throw error
        }
    }
}
