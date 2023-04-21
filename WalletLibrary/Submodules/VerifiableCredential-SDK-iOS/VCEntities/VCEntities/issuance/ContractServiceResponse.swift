/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct ContractServiceResponse: Codable, Equatable {
    let token: String
    
    init(token: String) {
        self.token = token
    }
}
