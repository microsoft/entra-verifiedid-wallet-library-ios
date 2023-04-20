/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct ContractServiceResponse: Codable, Equatable {
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
}
