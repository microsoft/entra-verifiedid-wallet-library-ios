/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

enum VerifiedIdPresentationRequestError: Error {
    case cancelPresentationRequestIsUnsupported
}

/**
 * Presentation Requst that is Open Id specific.
 */
class OpenIdPresentationRequest: VerifiedIdPresentationRequest 
{
    /// The look and feel of the requester.
    let style: RequesterStyle
    
    /// The requirement needed to fulfill request.
    let requirement: Requirement
    
    /// The root of trust results between the request and the source of the request.
    let rootOfTrust: RootOfTrust
    
    private let audience: URL
    
    private let rawRequest: any OpenIdRawRequest
    
    private let responder: OpenIdResponder
    
    private let configuration: LibraryConfiguration
    
    private let presentationExchangeSerializer: PresentationExchangeSerializer
    
    init(style: RequesterStyle,
         requirement: Requirement,
         rootOfTrust: RootOfTrust,
         rawRequest: any OpenIdRawRequest,
         responder: OpenIdResponder,
         configuration: LibraryConfiguration) throws
    {
        self.style = style
        self.requirement = requirement
        self.rootOfTrust = rootOfTrust
        self.rawRequest = rawRequest
        self.responder = responder
        self.configuration = configuration
        self.presentationExchangeSerializer = try PresentationExchangeSerializer(request: rawRequest,
                                                                                 libraryConfiguration: configuration)
        self.audience = try rawRequest.getRequiredProperty(property: rawRequest.responseURL,
                                                           propertyName: "responseURL")
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
        return await VerifiedIdResult<Void>.getResult {
            var response = try PresentationResponseContainer(rawRequest: self.rawRequest)
            try response.add(requirement: self.requirement)
            try await self.responder.send(response: response)
        }
    }
    
    func completeWithSerializer() async -> VerifiedIdResult<Void>
    {
        return await VerifiedIdResult<Void>.getResult {
            let verifiedIdSerializer = VerifiableCredentialSerializer()
            try self.presentationExchangeSerializer.serialize(requirement: self.requirement,
                                                              verifiedIdSerializer: verifiedIdSerializer)
            let response = try self.presentationExchangeSerializer.build()
            _ = try await self.configuration.networking.post(requestBody: response,
                                                             url: self.audience,
                                                             PostPresentationResponseOperation.self)
        }
    }
    
    /// Cancel the request with an optional message.
    func cancel(message: String?) async -> VerifiedIdResult<Void> 
    {
        return VerifiedIdError(message: message ?? "User Canceled.", 
                               code: VerifiedIdErrors.ErrorCode.UserCanceled).result()
    }
}
