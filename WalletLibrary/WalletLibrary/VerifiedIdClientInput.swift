/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

public protocol ResolvedInput {
    var type: InputType { get }
    
    var style: RequesterStyle { get }
    
    var requirement: Requirement { get }

    var rootOfTrust: RootOfTrust { get }
}

public protocol VerifiedIdClientInput {
    func resolve() async -> ResolvedInput
}

public class MockVerifiedIdClientInput: VerifiedIdClientInput {
    
    private let uri: String
    
    public init(uri: String) {
        self.uri = uri
    }
    
    public func resolve() async -> ResolvedInput {
        return MockResolvedInput(title: uri)
    }

}

struct MockResolvedInput: ResolvedInput {
    
    var type: InputType = .Issuance
    
    var style: RequesterStyle
    
    var verifiedIdStyle: VerifiedIdStyle
    
    var requirement: Requirement
    
    var rootOfTrust: RootOfTrust = RootOfTrust(verified: true, source: "test")
    
    init(title: String, requirement: Requirement = MockRequirement()) {
        self.requirement = requirement
        self.verifiedIdStyle = MockVerifiedIdStyle(title: "Verified Employee")
        self.style = MockRequesterStyle(requester: "sydney")
    }
}

