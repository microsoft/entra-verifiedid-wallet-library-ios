/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct IssuerDescriptor: Codable, Equatable {
    
    public let iss: String?
    
    public init(iss: String? = nil) {
        self.iss = iss
    }
}
