/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct ClaimDisplayDescriptor: Codable, Equatable {
    
    public let type: String
    public let label: String
    
    public init(type: String, label: String) {
        self.type = type
        self.label = label
    }
}
