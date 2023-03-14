/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents in a Verified Id Issuance Request.
 * This object is used to map protocol specific requests to common request object.
 * TODO: add VerifiedIdStyle to Issuance Content.
 */
struct IssuanceRequestContent {
    
    private struct Constants {
        static let IdTokenHintKey = "https://self-issued.me"
    }
    
    let style: RequesterStyle
    
    var requirement: Requirement
    
    let rootOfTrust: RootOfTrust
    
    mutating func addRequirement(from injectedIdToken: InjectedIdToken) {
        switch (requirement) {
        case var groupRequirement as GroupRequirement:
            repopulate(groupRequirement: groupRequirement, from: injectedIdToken)
        case let idTokenRequirement as IdTokenRequirement:
            add(injectedIdToken: injectedIdToken,
                to: idTokenRequirement)
        default:
            return
        }
    }
    
    private mutating func add(injectedIdToken: InjectedIdToken,
                              to idTokenRequirement: IdTokenRequirement) {
        if idTokenRequirement.configuration.absoluteString == Constants.IdTokenHintKey {
            idTokenRequirement.fulfill(with: injectedIdToken.rawToken)
            if let pinRequirement = injectedIdToken.pin {
                requirement = GroupRequirement(required: false,
                                               requirements: [idTokenRequirement, pinRequirement],
                                               requirementOperator: .ALL)
            }
        }
    }
    
    private func repopulate(groupRequirement: GroupRequirement,
                            from injectedIdToken: InjectedIdToken) {
        for requirement in groupRequirement.requirements {
            if let idTokenRequirement = requirement as? IdTokenRequirement {
                idTokenRequirement.fulfill(with: injectedIdToken.rawToken)
                if let pinRequirement = injectedIdToken.pin {
                    groupRequirement.requirements.append(pinRequirement)
                }
            }
        }
    }
}
