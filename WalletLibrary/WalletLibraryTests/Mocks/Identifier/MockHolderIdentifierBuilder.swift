/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockHolderIdentifierBuilder: HolderIdentifierBuilder
{
    private let expectedErrorToThrow: Error?
    
    private let expectedHolderIdentifier: HolderIdentifier?
    
    init(expectedErrorToThrow: Error?, 
         expectedHolderIdentifier: HolderIdentifier?)
    {
        self.expectedErrorToThrow = expectedErrorToThrow
        self.expectedHolderIdentifier = expectedHolderIdentifier
    }
    
    func buildHolderIdentifier(didMethod: String,
                               id: String?,
                               keyId: UUID?,
                               keyReference: String,
                               algorithm: String) throws -> HolderIdentifier
    {
        if let error = expectedErrorToThrow
        {
            throw error
        }
        
        return expectedHolderIdentifier ?? MockHolderIdentifier()
    }
}
