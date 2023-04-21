/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct IssuanceMetadata: Codable, Equatable {
    
    let contract: String?
    
    let issuerDid: String?
    
    init(contract: String?, issuerDid: String?) {
        self.contract = contract
        self.issuerDid = issuerDid
    }

    enum CodingKeys: String, CodingKey {
        case contract = "manifest"
        case issuerDid = "did"
    }
}
