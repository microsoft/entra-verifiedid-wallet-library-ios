/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Input to initiate a Verified Id Flow.
 */
public protocol VerifiedIdClientInput { }

protocol InternalVerifiedIdClientInput: VerifiedIdClientInput {
    /// Resolves the input.
    func resolve(with configuration: VerifiedIdClientConfiguration) throws -> RequestProtocol
}

struct MockResolvedInput: ResolvedInput {
    
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

