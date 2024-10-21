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
    
    init(expectedSignature: Data? = nil,
         id: String = "",
         algorithm: String = "",
         method: String = "",
         keyReference: String = "") {
        self.id = id
        self.algorithm = algorithm
        self.method = method
        self.keyReference = keyReference
        self.expectedSignature = expectedSignature
    }
    
    func sign(message: Data) throws -> Data 
    {
        return expectedSignature ?? Data()
    }
}
