/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockIssuanceResponseContainer: IssuanceResponseContaining {
    
    private let mockAddRequirementCallback: ((Requirement) throws -> Void)?
    
    init(mockAddRequirementCallback: ((Requirement) throws -> Void)? = nil) {
        self.mockAddRequirementCallback = mockAddRequirementCallback
    }
    
    mutating func add(requirement: Requirement) throws {
        try mockAddRequirementCallback?(requirement)
    }
}
