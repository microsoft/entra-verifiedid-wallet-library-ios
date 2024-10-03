/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

struct Contract: Claims, Equatable {
    
    let id: String
    let display: DisplayDescriptor
    let input: ContractInputDescriptor
    
    init(id: String,
         display: DisplayDescriptor,
         input: ContractInputDescriptor) {
        self.id = id
        self.display = display
        self.input = input
    }
    
}

typealias SignedContract = JwsToken<Contract>
