/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockHolderIdentifierStorage: HolderIdentifierStorage
{
    private let expectedErrorToThrowForFetching: Error?
    
    private let expectedErrorToThrowForStoring: Error?
    
    private let expectedErrorToTHrowForDeleting: Error?
    
    private let expectedHolderIdentifierProperties: [HolderIdentifierStoredProperties]
    
    init(expectedErrorToThrowForFetching: Error?,
         expectedErrorToThrowForStoring: Error?,
         expectedHolderIdentifierProperties: [HolderIdentifierStoredProperties] = [],
         expectedErrorToThrowForDeleting: Error?)
    {
        self.expectedErrorToThrowForFetching = expectedErrorToThrowForFetching
        self.expectedErrorToThrowForStoring = expectedErrorToThrowForStoring
        self.expectedHolderIdentifierProperties = expectedHolderIdentifierProperties
        self.expectedErrorToTHrowForDeleting = expectedErrorToThrowForDeleting
    }
    
    func fetchStoredHolderIdentifiers() throws -> [HolderIdentifierStoredProperties]
    {
        if let error = expectedErrorToThrowForFetching
        {
            throw error
        }
        
        return expectedHolderIdentifierProperties
    }
    
    func storeHolderIdentifier(holderIdentifier: HolderIdentifierStoredProperties) throws
    {
        if let error = expectedErrorToThrowForStoring
        {
            throw error
        }
    }
    
    func deleteHolderIdentifier(identifier: any WalletLibrary.HolderIdentifierStoredProperties) throws
    {
        if let error = expectedErrorToTHrowForDeleting
        {
            throw error
        }
    }
}
