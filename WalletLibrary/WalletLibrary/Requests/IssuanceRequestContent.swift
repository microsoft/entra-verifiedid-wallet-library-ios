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
    
    let style: RequesterStyle
    
    var requirement: Requirement
    
    let rootOfTrust: RootOfTrust
    
    mutating func addRequirement(from injectedIdToken: InjectedIdToken) {
        switch (requirement) {
        case var groupRequirement as GroupRequirement:
            repopulateGroupRequirementIfInjectedIdTokenExists(injectedIdToken: injectedIdToken,
                                                              groupRequirement: &groupRequirement)
        case let idTokenRequirement as IdTokenRequirement:
            idTokenRequirement.fulfill(with: injectedIdToken.rawToken)
            if let pinRequirement = injectedIdToken.pin {
                requirement = GroupRequirement(required: false,
                                               requirements: [idTokenRequirement, pinRequirement],
                                               requirementOperator: .ALL)
            }
        default:
            return
        }
    }
    
    private func repopulateGroupRequirementIfInjectedIdTokenExists(injectedIdToken: InjectedIdToken,
                                                                   groupRequirement: inout GroupRequirement) {
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

