/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockRawManifest: RawManifest, Equatable {
    
    enum MockRawManifesetError: Error {
        case mappingNotSupported
    }
    
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
    func map(using mapper: Mapping) throws -> IssuanceRequestContent {
        throw MockRawManifesetError.mappingNotSupported
    }
}
