/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents in a Verified Id Request.
 * This object is used to map protocol specific requests to common request object.
 * TODO: make this object extensible by separating Presentation with Issuance esp. for InjectedIdToken logic.
 * TODO: add VerifiedIdStyle to Issuance Content.
 */
struct PresentationRequestContent {
    
    let style: RequesterStyle
    
    var requirement: Requirement
    
    let rootOfTrust: RootOfTrust
    
    let injectedIdToken: InjectedIdToken?
    
    let raw: RawRequest
    
    init(style: RequesterStyle,
         requirement: Requirement,
         rootOfTrust: RootOfTrust,
         raw: RawRequest,
         injectedIdToken: InjectedIdToken? = nil) {
        self.style = style
        self.requirement = requirement
        self.rootOfTrust = rootOfTrust
        self.raw = raw
        self.injectedIdToken = injectedIdToken
    }
}

struct IssuanceRequestContent: RequestContent {
    
    let style: RequesterStyle
    
    var requirement: Requirement
    
    let rootOfTrust: RootOfTrust
    
    let raw: RawRequest
    
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

protocol RawRequest {
    
}


protocol RequestContent {
    
    var style: RequesterStyle { get }
    
    var requirement: Requirement { get }
    
    var rootOfTrust: RootOfTrust { get }
    
    var raw: RawRequest { get }
}
