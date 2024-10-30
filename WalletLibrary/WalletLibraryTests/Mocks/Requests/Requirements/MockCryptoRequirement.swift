/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockCryptoRequirement: CryptoRequirement
{
    
    let expectedIdentifierId: String
    
    init(expectedIdentifierId: String = "")
    {
        self.expectedIdentifierId = expectedIdentifierId
    }
    
    func isSupported(identifier: HolderIdentifier) -> Bool
    {
        expectedIdentifierId == identifier.id
    }
}
