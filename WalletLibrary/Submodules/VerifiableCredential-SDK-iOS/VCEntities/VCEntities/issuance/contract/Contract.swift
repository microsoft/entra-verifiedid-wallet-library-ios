/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

#if canImport(VCToken)
    import VCToken
#endif

public struct Contract: Claims, Equatable {
    
    public let id: String
    public let display: DisplayDescriptor
    public let input: ContractInputDescriptor
    
    public init(id: String,
                display: DisplayDescriptor,
                input: ContractInputDescriptor) {
        self.id = id
        self.display = display
        self.input = input
    }
    
}

public typealias SignedContract = JwsToken<Contract>
