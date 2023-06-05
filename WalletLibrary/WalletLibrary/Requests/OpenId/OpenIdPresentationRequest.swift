/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

#if canImport(VCEntities)
    import VCEntities
#endif

enum VerifiedIdPresentationRequestError: Error {
    case cancelPresentationRequestIsUnsupported
}

/**
 * Presentation Requst that is Open Id specific.
 */
class OpenIdPresentationRequest: VerifiedIdPresentationRequest {
    
    /// The look and feel of the requester.
    let style: RequesterStyle
    
    /// The requirement needed to fulfill request.
    let requirement: Requirement
    
    /// The root of trust results between the request and the source of the request.
    let rootOfTrust: RootOfTrust
    
    private let rawRequest: any OpenIdRawRequest
    
    private let responder: OpenIdResponder
    
    private let configuration: LibraryConfiguration
    
    init(content: PresentationRequestContent,
         rawRequest: any OpenIdRawRequest,
         openIdResponder: OpenIdResponder,
         configuration: LibraryConfiguration) {
        
        self.style = content.style
        self.requirement = content.requirement
        self.rootOfTrust = content.rootOfTrust
        self.rawRequest = rawRequest
        self.responder = openIdResponder
        self.configuration = configuration
    }
    
    /// Whether or not the request is satisfied on client side.
    func isSatisfied() -> Bool {
        do {
            try requirement.validate().get()
            return true
        } catch {
            /// TODO: log error.
            return false
        }
    }
    
    /// Completes the request and returns a Result object containing void if successful, and an error if not successful.
    func complete() async -> VerifiedIdResult<Void> {
        do {
            var response = try PresentationResponseContainer(rawRequest: rawRequest)
            try response.add(requirement: requirement)
            try await responder.send(response: response)
            return Result.success(())
        } catch {
            return VerifiedIdErrors.UnspecifiedError(error: error).result()
        }
    }
    
    /// Cancel the request with an optional message.
    func cancel(message: String?) async -> VerifiedIdResult<Void> {
        return VerifiedIdErrors.UnspecifiedError(error: VerifiedIdError(message: "test", code: "test")).result()
    }
}
