/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct ConsentDisplayDescriptor: Codable, Equatable {
    
    let title: String?
    let instructions: String

    init(title: String?, instructions: String) {
        self.title = title
        self.instructions = instructions
    }
}
