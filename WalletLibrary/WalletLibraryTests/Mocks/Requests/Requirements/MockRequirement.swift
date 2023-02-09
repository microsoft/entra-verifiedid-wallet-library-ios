/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockRequirement: Requirement, Equatable {
    
    let required: Bool
    
    let id: String
    
    let mockValidateCallback: (() throws -> Void)?
    
    init(id: String, required: Bool = true, mockValidateCallback: (() throws -> Void)? = nil) {
        self.id = id
        self.required = required
        self.mockValidateCallback = mockValidateCallback
    }
    
    func validate() throws {
        try mockValidateCallback?()
    }
    
    static func == (lhs: MockRequirement, rhs: MockRequirement) -> Bool {
        return lhs.id == rhs.id
    }
}
