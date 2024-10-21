/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockHolderIdentifier: HolderIdentifier
{
    var id: String
    
    var algorithm: String
    
    var method: String
    
    var keyReference: String
    
    private let expectedSignature: Data?
    
    private let expectedErrorToBeThrown: Error?
    
    init(expectedSignature: Data? = nil,
         expectedErrorToBeThrown: Error? = nil,
         id: String = "",
         algorithm: String = "",
         method: String = "",
         keyReference: String = "") 
    {
        self.id = id
        self.algorithm = algorithm
        self.method = method
        self.keyReference = keyReference
        self.expectedSignature = expectedSignature
        self.expectedErrorToBeThrown = expectedErrorToBeThrown
    }
    
    func sign(message: Data) throws -> Data 
    {
        if let expectedErrorToBeThrown = expectedErrorToBeThrown
        {
            throw expectedErrorToBeThrown
        }
        
        return expectedSignature ?? Data()
    }
}
