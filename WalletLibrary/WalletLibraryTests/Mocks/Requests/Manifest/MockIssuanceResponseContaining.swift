/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

@testable import WalletLibrary

struct MockIssuanceResponseContainer: IssuanceResponseContaining {
    
    let audienceUrl: String
    
    private let mockAddRequirementCallback: ((Requirement) throws -> Void)?
    
    init(audienceUrl: String = "",
         mockAddRequirementCallback: ((Requirement) throws -> Void)? = nil) {
        self.audienceUrl = audienceUrl
        self.mockAddRequirementCallback = mockAddRequirementCallback
    }
    
    mutating func add(requirement: Requirement) throws {
        try mockAddRequirementCallback?(requirement)
    }
}
