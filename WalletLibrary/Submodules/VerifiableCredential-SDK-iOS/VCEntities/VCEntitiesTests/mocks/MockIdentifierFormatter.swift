/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockIdentifierFormatter: IdentifierFormatting {
    
    let returningString: String
    
    init(returningString: String) {
        self.returningString = returningString
    }
    
    func createIonLongFormDid(recoveryKey: PublicJWK, updateKey: PublicJWK, didDocumentKeys: [PublicJWK], serviceEndpoints: [IdentifierDocumentServiceEndpoint]) throws -> String {
        return self.returningString
    }
}
