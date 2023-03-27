/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Contents in a Verified Id Presentation Request.
 * This object is used to map protocol specific requests to common request object.
 */
struct PresentationRequestContent {
    
    let style: RequesterStyle
    
    var requirement: Requirement
    
    let rootOfTrust: RootOfTrust
    
    let requestState: String
    
    let callbackUrl: URL
    
    let injectedIdToken: InjectedIdToken?
    
    init(style: RequesterStyle,
         requirement: Requirement,
         rootOfTrust: RootOfTrust,
         requestState: String,
         callbackUrl: URL,
         injectedIdToken: InjectedIdToken? = nil) {
        self.style = style
        self.requirement = requirement
        self.rootOfTrust = rootOfTrust
        self.requestState = requestState
        self.callbackUrl = callbackUrl
        self.injectedIdToken = injectedIdToken
    }
}
