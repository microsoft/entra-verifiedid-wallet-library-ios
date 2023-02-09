/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Presentation Requst that is Open Id specific.
 * TODO: we will need open id specific data to implement complete and cancel.
 */
class OpenIdPresentationRequest: VerifiedIdPresentationRequest {
    
    let style: RequesterStyle
    
    let requirement: Requirement
    
    let rootOfTrust: RootOfTrust
    
    private let configuration: LibraryConfiguration
    
    init(content: VerifiedIdRequestContent, configuration: LibraryConfiguration) {
        self.style = content.style
        self.requirement = content.requirement
        self.rootOfTrust = content.rootOfTrust
        self.configuration = configuration
    }
    
    /// TODO: implement.
    func isSatisfied() -> Bool {
        return false
    }
    
    func complete() async -> Result<(), Error> {
        return Result.failure(VerifiedIdClientError.TODO(message: "implement"))
    }
    
    func cancel(message: String?) -> Result<Void, Error> {
        return Result.failure(VerifiedIdClientError.TODO(message: "implement"))
    }
}
