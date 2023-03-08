/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities

/**
 * Presentation Requst that is Open Id specific.
 * TODO: we will need open id specific data to implement complete and cancel.
 */
class OpenIdPresentationRequest: VerifiedIdPresentationRequest {
    
    let style: RequesterStyle
    
    let requirement: Requirement
    
    let rootOfTrust: RootOfTrust
    
    private let raw: any OpenIdRawRequest
    
    private let responder: OpenIdForVCResponder
    
    private let configuration: LibraryConfiguration
    
    init(content: PresentationRequestContent,
         openIdResponder: OpenIdForVCResponder,
         configuration: LibraryConfiguration) throws {
        
        guard let raw = content.raw as? any OpenIdRawRequest else {
            throw VerifiedIdClientError.TODO(message: "test")
        }
        
        self.style = content.style
        self.requirement = content.requirement
        self.rootOfTrust = content.rootOfTrust
        self.raw = raw
        self.responder = openIdResponder
        self.configuration = configuration
    }
    
    /// TODO: implement.
    func isSatisfied() -> Bool {
        return false
    }
    
    func complete() async -> Result<(), Error> {
        do {
            
            var response = try PresentationResponseContainer(from: raw)
            try response.add(requirement: requirement)
            try await responder.send(response: response)
            return Result.success(())
        } catch {
            return Result.failure(error)
        }
    }
    
    func cancel(message: String?) -> Result<Void, Error> {
        return Result.failure(VerifiedIdClientError.TODO(message: "implement"))
    }
}
