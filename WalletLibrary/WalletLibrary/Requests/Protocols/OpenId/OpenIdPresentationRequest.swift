/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

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
