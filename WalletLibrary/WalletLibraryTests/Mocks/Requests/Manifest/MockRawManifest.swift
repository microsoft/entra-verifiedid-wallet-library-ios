/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockRawManifest: RawManifest, Equatable {
    
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
    func map(using mapper: Mapping) throws -> IssuanceRequestContent {
        throw VerifiedIdClientError.TODO(message: "implement")
    }
}
