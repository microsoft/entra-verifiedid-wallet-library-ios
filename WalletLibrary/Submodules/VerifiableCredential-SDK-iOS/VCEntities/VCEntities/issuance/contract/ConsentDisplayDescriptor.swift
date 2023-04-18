/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public struct ConsentDisplayDescriptor: Codable, Equatable {
    
    public let title: String?
    public let instructions: String

    public init(title: String?, instructions: String) {
        self.title = title
        self.instructions = instructions
    }
}
