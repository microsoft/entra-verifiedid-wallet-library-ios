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
    
    let injectedIdToken: InjectedIdToken?
    
    init(style: RequesterStyle,
         requirement: Requirement,
         rootOfTrust: RootOfTrust,
         injectedIdToken: InjectedIdToken? = nil) {
        self.style = style
        self.requirement = requirement
        self.rootOfTrust = rootOfTrust
        self.injectedIdToken = injectedIdToken
    }
}
